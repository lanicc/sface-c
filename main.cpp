#include <stdio.h>
#include <map>
#include <string>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>
#include <sys/stat.h>
#include <unistd.h>
#include <time.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include "dhnetsdk.h"
#include "dhconfigsdk.h"
#include <iostream>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#include <iostream>
#include <string>
#include <cstring>
#include <unistd.h>
#include <pthread.h>
#include <vector>

using namespace std;

//	Camera disconnect status can be callback-ed
void on_disconnect(LLONG uid, char *host, LONG port, LDWORD user) {
    printf("camera(%s) disconnect\n", host);
}

//	Camera reconnect successfully
void on_success_relogin(LLONG uid, char *host, LONG port, LDWORD user) {
    printf("camera(%s) relogin ok\n", host);
}

LLONG login(const string &ip, const short &port, const string &user, const string &passwd) {

    printf("Login cam ip[%s],port[%d],user[%s],passwd[%s]\n", ip.c_str(), port, user.c_str(), passwd.c_str());

    int errcode = 0;
    NET_DEVICEINFO stLoginInfo = {0};
    LLONG userid = CLIENT_LoginEx(ip.c_str(), port, user.c_str(), passwd.c_str(), 0, nullptr, &stLoginInfo, &errcode);
    if (0 == userid) {
        printf("Login cam[%s] error(%d)\n", ip.c_str(), errcode);
    }

    return userid;
}





struct Sock {
    int sock;
};

struct Camera {
    string ip;
    int port;
    string user;
    string password;
    int sock;
};


vector<Camera> cameraVector;
string serverIp = "10.20.0.130";
int serverPort = 8080;


vector<string> parse_str(string s) {
    vector<string> vector;
    while (!s.empty()) {
        int index = s.find(',', 0);
        if (index == -1) {
            vector.push_back(s);
            break;
        }

        string sub = s.substr(0, index);
        vector.push_back(sub);
        s = s.substr(index + 1);
    }

    return vector;
}

int create_sock() {
    struct sockaddr_in server_listen_addr;
    int sock;
    bzero(&server_listen_addr, sizeof(server_listen_addr));
    server_listen_addr.sin_family = AF_INET;
    server_listen_addr.sin_port = htons(serverPort);
    inet_pton(AF_INET, serverIp.c_str(), (void *) &server_listen_addr.sin_addr);
    sock = socket(AF_INET, SOCK_STREAM, 0);
    int ret = connect(sock, (const struct sockaddr *) &server_listen_addr, sizeof(struct sockaddr));
    printf("server_fd=[%d] ret=[%d]n", sock, ret);
    if (ret < 0) {
        perror("error: socket connect!");
        return 0;
    }
    return sock;
}

void print_vector() {
    cout << "cameraVector.size: " << cameraVector.size() << endl;
    for (int i = 0; i < cameraVector.size(); ++i) {
        cout << "ip: " << cameraVector[i].ip << "\tport: " << cameraVector[i].port << "\nuser: " << cameraVector[i].user
             << "\tpassword: " << cameraVector[i].password << "\tsock: " << cameraVector[i].sock << endl;
    }
}

void clear_vector() {
    for (int i = 0; i < cameraVector.size(); ++i) {
        if (cameraVector[i].sock) {
            try {
                close(cameraVector[i].sock);
            } catch (const char *pMsg) {
                perror("error: socket close error when clear!");
                cout << cameraVector[i].ip << pMsg << endl;
            }
        }
        cout << "ip: " << cameraVector[i].ip << "\tport: " << cameraVector[i].port << "\nuser: " << cameraVector[i].user
             << "\tpassword: " << cameraVector[i].password << "\tsock: " << cameraVector[i].sock << endl;
    }
    cameraVector.clear();
}

struct Camera push_vector(struct Camera camera) {
    for (int i = 0; i < cameraVector.size(); ++i) {
        if (cameraVector[i].ip == camera.ip && cameraVector[i].port == cameraVector[i].port) {
            cameraVector[i].user = camera.user;
            cameraVector[i].password = camera.password;
            if (cameraVector[i].sock == 0) {
                cameraVector[i].sock = create_sock();
            }
            return cameraVector[i];
        }
    }
    camera.sock = create_sock();
    cameraVector.push_back(camera);
    return camera;
}

void send_data(int sock, char data[], int len) {
    string dataSend = to_string(len).append("#").append(data);
    send(sock, (void *) dataSend.c_str(), dataSend.length(), 0);
}

int CALLBACK AnalyzerDataCallBack(LLONG lAnalyzerHandle, DWORD dwAlarmType, void* pAlarmInfo, BYTE* pBuffer, DWORD dwBufSize, LDWORD dwUser, int nSequence, void* reserved) {
    printf("receive on pic\n");
    cout  << "dwAlarmType = " << dwAlarmType << "\t" << dwBufSize << endl;
    char *p = reinterpret_cast< char *>(pBuffer);
    send_data(dwUser, p, dwBufSize);
    return 1;
}

void start_listen(struct Camera camera) {
    int sock = camera.sock;
    //    //	Init sdk
    if (!CLIENT_Init(on_disconnect, sock)) {
        printf("init sdk error(%d)\n", CLIENT_GetLastError());
        return;
    }

    CLIENT_SetAutoReconnect(&on_success_relogin, 0);
    LLONG userid = login(camera.ip, camera.port, camera.user, camera.password);
    if (0 != userid) {
        CLIENT_RealLoadPictureEx(userid, 0, EVENT_IVS_ALL, TRUE, AnalyzerDataCallBack, sock, NULL);
    }
}

void process_msg(int command, char msg[], int len) {
    cout << "command: " << command << endl;
    switch (command) {
        case 0:
            clear_vector();
            break;
        case 1:
            vector<string> strVector = parse_str(msg);
            struct Camera camera;
            camera.ip = strVector[0];
            camera.port = stoi(strVector[1]);
            camera.user = strVector[2];
            camera.password = strVector[3];

            camera = push_vector(camera);
            start_listen(camera);

            break;
//        case '2':
//
//            break;
//        default:
//            break;
    }
    print_vector();
}

void sock_read(int sock, int len, char dataArr[]) {
    int recvedSize = 0;
    char dataArrTmp[len];
    while (recvedSize < len) {
        int recvSize = recv(sock, dataArrTmp, (len - recvedSize) * sizeof(char), 0);
        for (int i = 0; i < recvSize; ++i) {
            if (i + recvedSize < len) {
                dataArr[i + recvedSize] = dataArrTmp[i];
            }
//            cout << dataArrTmp[i] << endl;
        }
        recvedSize += recvSize;
    }
}

/**
 * protocol
 * Begin | LenField: 4bytes | CommandField: 2bytes | DataField | End
 * LenField = len(CommandField) + len(DataField)
 * @param sockStruct
 * @return
 */
void *process_sock(void *sockStruct) {
    struct Sock *s;
    s = (struct Sock *) sockStruct;

    int sock = s->sock;

    // 接收客户端发送过来的数据

    //lenField
    const unsigned short msgLenField = 4;
    char lenArr[msgLenField + 1];
    lenArr[msgLenField] = '\0';
    sock_read(sock, msgLenField, lenArr);
    int allLen = stoi(lenArr);
    std::cout << "LenField：" << allLen << std::endl;

    //CommandField
    const int msgCommandLenField = 2;
    char commandArr[msgCommandLenField + 1];
    commandArr[msgCommandLenField] = '\0';
    sock_read(sock, msgCommandLenField, commandArr);
    int command = stoi(commandArr);

    //DataField
    int len = allLen - msgCommandLenField;
    char dataArr[len];
    sock_read(sock, len, dataArr);

    //process_msg
    process_msg(command, dataArr, len);

    // 发送数据给客户端
    if (send(sock, dataArr, len, 0) != len)
        std::cout << "Send message to client error." << std::endl;

    // 关闭客户端的连接，释放客户端套接字对象
    close(sock);
}

void *create_server(void *args) {
    std::cout << "Hello, World!" << std::endl;

    try {
        // 创建服务端套接字
        int so = socket(AF_INET, SOCK_STREAM, 0);
        if (so == -1) throw "Create socket error.";

        // 绑定服务端套接字到指定的IP与Port上
        sockaddr_in addr;
        addr.sin_family = AF_INET;
        addr.sin_port = htons(9089);
        addr.sin_addr.s_addr = INADDR_ANY;
        if (bind(so, (sockaddr *) &addr, sizeof(sockaddr_in)) == -1) {
            throw "绑定套截字失败";
            exit(-1);
        }

        // 监听套接字
        if (listen(so, 5) == -1) throw "监听套接字失败";
        std::cout << "Start server finish ..." << std::endl;


        while (true) {
            // 初始化客户端信息存储地址
            int soClient = 0;
            int nClientAddSize = sizeof(sockaddr_in);
            sockaddr_in addrClient;
            memset(&addrClient, 0, sizeof(sockaddr_in));

            // 接收客户端的连接请求
            soClient = accept(so, (sockaddr *) &addrClient, (socklen_t *) &nClientAddSize);
            if (soClient == -1)continue;
            std::cout << "接收到新连接: " << soClient << std::endl;


            struct Sock sock;
            sock.sock = soClient;
            pthread_t tid;
            int ret = pthread_create(&tid, NULL, process_sock, (void *) &(sock));
            if (ret != 0) {
                std::cout << "pthread_create error: error_code=" << ret << std::endl;
            }
        }
        // 释放服务端的套接字对象
        close(so);
    } catch (const char *pMsg) {
        std::cout << pMsg << std::endl;
    }
}




int main(int argc, char const *argv[]) {
    //create_server();
//    string ip = argv[1];
//    short port = (short) atoi(argv[2]);
//    string user = argv[3];
//    string passwd = argv[4];
//
//    //	Init sdk
//    if (!CLIENT_Init(on_disconnect, 0)) {
//        printf("init sdk error(%d)\n", CLIENT_GetLastError());
//        return -1;
//    }
//
//    CLIENT_SetAutoReconnect(&on_success_relogin, 0);
//    LLONG userid = login(ip, port, user, passwd);
//    if (0 != userid) {
////		if (ST_ERR == dispose(ip, userid)) {
////			printf("dispose error\n");
////		}
////        LLONG lRealHandle = CLIENT_RealPlayEx(userid, 0, NULL);
////        printf("okok");
////        DWORD dwFlag = 0x00000001;
////        CLIENT_SetRealDataCallBackEx(lRealHandle, &RealDataCallBackEx, NULL, dwFlag);
//
//
//        CLIENT_RealLoadPictureEx(userid, 0, EVENT_IVS_ALL, TRUE, AnalyzerDataCallBack, 0, NULL);
//
//    }

    pthread_t tid;
    int ret = pthread_create(&tid, NULL, create_server, NULL);
    if (ret != 0) {
        std::cout << "Server pthread_create error: error_code=" << ret << std::endl;
    }
    while (1) {
        sleep(2000);
    }
    return 0;
}