//
//  main.c
//  anytelnet
//
//  Created by 吴 锦城 on 2018/2/1.
//  Copyright © 2018年 wujincheng. All rights reserved.
//

#include <stdio.h>
#include <errno.h>
#include <string.h>
#include <termios.h>
#include <unistd.h>
#include <sys/socket.h>
#include <netinet/in.h>

#define MAX_LEN         2048
#define CMD             0xff
#define DO              0xfd
#define WONT            0xfc
#define WILL            0xfb
#define DONT            0xfe
#define CMD_ECHO        1
#define CMD_WIN_SIZE    31
#define IAC             255
#define SB              250
#define SE              240
#define BUFLEN          200
#define ESCAPE          200

static struct termios g_termios;
static int g_telnet_sd;

static int telent_win_size(int sock)
{
    const unsigned char win_size_reply[3] = {IAC, WILL, CMD_WIN_SIZE};
    const unsigned char cur_win_size[9] = {IAC, SB, CMD_WIN_SIZE, 0, 80, 0, 24, IAC, SE};
    ssize_t ret;

    ret = send(sock, win_size_reply, 3, 0);
    if (ret < 0) {
        printf("send windows size reply fail\r\n");
        return -1;
    }
    ret = send(sock, cur_win_size, 9, 0);
    if (ret < 0) {
        printf("send windows size fail\r\n");
        return -1;
    }

    return 0;
}

static int telnet_negotiate(int sock)
{
    ssize_t len;
    unsigned char buf[10] = {0};
    int i;
    
    len = recv(sock, buf + 1, 2, 0);
    if (len < 0) {
        return 1;
    } else if (len == 0) {
        printf("Connection closed by the remote end\r\n");
        return 0;
    }
    if (buf[1] == DO && buf[2] == CMD_WIN_SIZE) {
        return telent_win_size(sock);
    }
    for (i = 0; i < 2; i++) {
        if (buf[i] == DO) {
            buf[i] = WONT;
        } else if (buf[i] == WILL) {
            buf[i] = DO;
        }
    }
    buf[0] = CMD;
    len = send(sock, buf, 3, 0);
    if (len < 0) {
        printf("telnet negotiate fail\r\n");
        return -1;
    }
    
    return 0;
}

static int telnet_recv(int sock)
{
    unsigned char buf[10] = {0};
    ssize_t rv;
    
    rv = recv(sock, buf, 1, 0);
    if (rv == 0) {
        printf("Connection closed by the remote end\r\n");
        return 1;
    } else if (rv < 0) {
        printf("recv fail\r\n");
        return -1;
    }
    if (buf[0] == CMD) {
        if (telnet_negotiate(sock) < 0) {
            printf("negotiate fail\r\n");
            return -1;
        }
    } else {
        buf[1] = '\0';
        printf("%s", buf);
        fflush(stdout);
    }
    
    return 0;
}

static int telnetc_input(int sock)
{
    unsigned char buf[10] = {0};
    unsigned char crlf[2] = { '\r', '\n' };
    
    buf[0] = getc(stdin);
    if (buf[0] == '\n') { // with the terminal in raw mode we need to force a LF
        if (send(sock, crlf, 1, 0) < 0) {
            return -1;
        }
    } else if (buf[0] == ESCAPE) {
        printf("Connection closed by the client end\n\r");
        return 1;
    } else {
        if (send(sock, buf, 1, 0) < 0) {
            return -1;
        }
    }
    
    return 0;
}

void *telnetc_handle(void *data)
{
    fd_set fds;
    struct timeval ts;
    int sd, len, ret;
    
    sd = *((int *)data);
    ts.tv_sec = 1;
    ts.tv_usec = 0;
    while (1) {
        FD_ZERO(&fds);
        if (sd != 0) {
            FD_SET(sd, &fds);
        }
        FD_SET(0, &fds);
        len = select(sd + 1, &fds, 0, 0, &ts);
        if (len < 0) {
            printf("select error\r\n");
            continue;
        } else if (len == 0) {
            ts.tv_sec = 1;
            ts.tv_usec = 1;
        } else if (sd != 0 && FD_ISSET(sd, &fds)) {
            ret = telnet_recv(sd);
            if (ret != 0) {
                close(sd);
                exit(1);
                return NULL;
            }
        } else if (FD_ISSET(0, &fds)) {
            ret = telnetc_input(sd);
            if (ret != 0) {
                close(sd);
                exit(1);
                return NULL;
            }
        }
    }
    
    return NULL;
}

int create_socket(const char *ip, int portnum)
{
    int sd, rv;
    struct in_addr ipaddr;
    struct sockaddr_in srv_addr;
    
    sd = socket(AF_INET, SOCK_STREAM, 0);
    if (sd == -1) {
        printf("socket create fail, %s, %d\r\n", strerror(errno), errno);
        return -1;
    }
    memset(&ipaddr, 0, sizeof(struct in_addr));
    memset(&srv_addr, 0, sizeof(struct sockaddr_in));
    rv = inet_aton(ip, &ipaddr);
    if (rv == 0) {
        printf("inet_aton fail, %s, %d\r\n", strerror(errno), errno);
        return -1;
    }
    srv_addr.sin_family = AF_INET;
    srv_addr.sin_port = portnum ? htons(portnum) : htons(23); /* Telnet default port number is 23 */
    memcpy(&srv_addr.sin_addr, &ipaddr, sizeof(struct in_addr));
    rv = connect(sd, &srv_addr, sizeof(struct sockaddr_in));
    if (rv != 0) {
        printf("connected fail, %s, %d\r\n", strerror(errno), errno);
        return -1;
    }
    
    return sd;
}

static void terminal_set(void)
{
    static struct termios tmp;
    
    tcgetattr(STDIN_FILENO, &g_termios);
    memcpy(&tmp, &g_termios, sizeof(struct termios));
    cfmakeraw(&tmp);
    tcsetattr(STDIN_FILENO, TCSANOW, &tmp);
}

static void terminal_reset(void)
{
    tcsetattr(STDIN_FILENO, TCSANOW, &g_termios);
}

/**
 * anytelnet_send_and_recv_all
 * @ip: Server IP address
 * @port: Server Telnet Port
 */
char *anytelnet_send_and_recv_all(char *str)
{
    return NULL;
}

/**
  * anytelnet_init
  * @ip: Server IP address
  * @port: Server Telnet Port
  */
int anytelnet_init(char *ip, int port)
{
    pthread_t tid;
    int sd, rv;
    
    if (ip == NULL) {
        printf("ip addr is NULL.\r\n");
        return -1;
    }
    if (port < 0 || port > 65535) {
        printf("port is out of range.\r\n");
        return -1;
    }
    sd = create_socket(ip, port);
    if (sd == -1) {
        printf("create_socket fail.\r\n");
        return -1;
    }
    g_telnet_sd = sd;
    rv = pthread_create(&tid, NULL, telnetc_handle, (void *)&sd);
    if (rv != 0) {
        printf("pthread_create fail, %s, %d\r\n", strerror(errno), errno);
        return -1;
    }
    
    return 0;
}


int main(int argc, const char * argv[])
{
    int sd, rv;
    pthread_t tid;
    
    if (argc != 2) {
        printf("Usage: %s ipaddr(xxx.xxx.xxx.xxx) portnumber(Optional)\r\n", argv[0]);
        printf("demo: %s 192.168.1.3 23\r\n", argv[0]);
        return -1;
    }
    if (argc != 3) {
        sd = create_socket(argv[1], 0);
    } else {
        sd = create_socket(argv[1], atoi(argv[2]));
    }
    if (sd == -1) {
        printf("create_socket fail.\r\n");
        return -1;
    }
    puts("Escape character is '^]'.");
    terminal_set();
    atexit(terminal_reset);
    //telnetc_handle((void *)&sd);
    rv = pthread_create(&tid, NULL, telnetc_handle, (void *)&sd);
    if (rv != 0) {
        printf("pthread_create fail, %s, %d\r\n", strerror(errno), errno);
        return -1;
    }
    while (1) {
        sleep(1000);
    }
    
    return 0;
}
