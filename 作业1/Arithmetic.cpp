#include <iostream>
#include <iomanip>
#include <string>
#include <cmath>
#include <cstring>


using namespace std;

struct Charset {
    char ch;
    double p;
    double lowLevel;
    double highLevel;
};

char charRes[1000];
Charset charSet[100];
int n;
double L;
double H;

int Cast(char ch) {  // 将字符与位置对应
    int chNum = 0;
    for (int i = 0; i < n; i++) {
        if (ch == charSet[i].ch) {
            chNum = i;
            break;
        }
    }
    return chNum;
}

void ArithmeticEncode(char charSequence[]) { // 编码过程
    double lowLevel = 0.0;   // 初始区间
    double highLevel = 1.0;
    int length = strlen(charSequence); // 读取字符长度
    double interval;
    int chNum;

    // 对于每一个输入的字符，识别其区间，并且更新原区间，使得当前区间的下限为原区间的下限+原区间长度*字符下限
    // 使得当前区间的上限为原区间的下限+原区间长度*字符上限
    for (int i = 0; i < length; i++) {
        chNum = Cast(charSequence[i]);
        interval = highLevel - lowLevel;
        highLevel = lowLevel + interval * charSet[chNum].highLevel;
        lowLevel += interval * charSet[chNum].lowLevel;
    }
    L = lowLevel;
    H = highLevel;
}

void ArithmeticBinary(double L, double H) { // 二进制过程
    int binLength = 0;
    double sum1 = 0;
    double sum2 = 0;
    double t = L;
    cout << "0."; // 这里 "0." 方便表示，实际二进制串没有

    while (sum1 <= L)         //当未达到指定区间
    {
        int temp = int(t * 2);
        binLength++;
        sum2 = sum1 + pow(0.5, binLength);
        sum1 += temp * pow(0.5, binLength);
        if ((sum2 >= L && sum2 <= H) && sum1 <= L) {  //当最后一个字符为1时，二进制数处于区间内则说明该二进数为最短二进制数
            cout << 1;
            break;
        }
        cout << temp;
        t = 2 * t - int(2 * t); // 去整数
    }
}

int findChar(double code) {
    int num = 0;
    for (int i = 0; i < n; i++) {
        if (code <= charSet[i].highLevel && code >= charSet[i].lowLevel) {
            num = i;
            cout << charSet[i].ch;
        }
    }
    return num;
}

void ArithmeticDecode(double codeNum, int codeLength) {  // 解码过程
    double interval = 1.0;
    double lowLevel = 0.0;
    double highLevel = 0.0;
    double temp = codeNum;  
    // 对于每一个输入区间数值，识别是属于哪一个字符，并且更新原区间，使得当前区间的下限为原区间的下限+原区间长度*字符下限
    // 使得当前区间的上限为原区间的下限+原区间长度*字符上限，并更新当前的数值
    for(int i = 0; i < codeLength; i++){
        int j = findChar(temp);      
        highLevel = lowLevel + interval * charSet[j].highLevel;
        lowLevel += interval * charSet[j].lowLevel;
        interval = highLevel - lowLevel;
        temp = (codeNum - lowLevel) / interval;

    }
}

int main()
{   
    // Encode 过程
    char charSequence[1000];

    cout << "输入字符个数:";
    cin >> n;       
    
    double level=0.0;
    cout << "输入概率字典,格式为 (字符 概率）:" << endl;
    for (int i = 0; i < n; i++) {
        cin >> charSet[i].ch >> charSet[i].p;
        charSet[i].lowLevel = level;
        level += charSet[i].p;
        charSet[i].highLevel = level;
    }

    cout << "输入字符序列:" ;
    cin >> charSequence;

    ArithmeticEncode(charSequence);

    cout << "编码区间：";
    cout << setprecision(12) << L << " " << H << endl;

    cout << "最短二进制码：";
    ArithmeticBinary(L,H);
    cout << endl;


    //
    // Decode 过程  (以刚才得到的编码为例）
    //

    int codeLength;
    cout << "输入原字符串的字符长度：";
    cin >> codeLength;

    cout << "输入概率字典,格式为 (字符 概率）:" << endl;
    // 这里以 Encode 过程中的概率字典为例

    char binarySequence[1000];
    cout << "输入编码后的二进制串:";   // 为无符号位二进制串
    cin >> binarySequence;

    double codeNum = 0;
    for (int i = 0; i < strlen(binarySequence); i++) {
        if (binarySequence[i] != '0') {
            codeNum += pow(0.5, i+1);
        }
    }

    cout << "二进制串值为:";
    cout << setprecision(16) << codeNum << endl;

    cout << "解码为原来的字符串为：";

    ArithmeticDecode(codeNum,codeLength);

    return 0;
}

