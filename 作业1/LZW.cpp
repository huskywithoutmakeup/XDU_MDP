#include<iostream>
#include<string>
#include<cstring>

#define N 500

using namespace std;

class LZW{ 
public:
	char encodeStr[N];		//需编码的字符串
	int decodeList[N];		//译码的数组
	int preDictionaryNum;   //先前词典的大小 
	int length;				//当前词典的大小 
	char dictionary[N][N];	//先前词典
	
	
	LZW(){					
		encodeStr[0] = '\0';
		preDictionaryNum = 0;
		length = 0;
		
		for (int i = 0; i < N; i++) {
			this->decodeList[i]=-1;
		}
		
		for (int i = 0; i < N; i++) {
			this->dictionary[i][0] = '\0';
		}
	}
	
	
	bool initDictionary() 		        //初始化先前词典
	{	
		if(encodeStr[0]=='\0'){			//若没有要编码的字符串，则不能生成先前词典 
			return false;
		}

		dictionary[0][0] = encodeStr[0];//将要编码的字符串的第一个字符加入先前词典 
		dictionary[0][1] = '\0';        // 单字符，则后接结束符
		length = 1;

		int i, j;

		for (i = 1; encodeStr[i] != '\0'; i++) {          //将要编码的字符串中所有不同的字符加入先前词典 
			for (j = 0; dictionary[j][0] != '\0'; j++) {
				if(dictionary[j][0] == encodeStr[i]){
					break;
				}
			}

			if(dictionary[j][0]=='\0'){
				dictionary[j][0] = encodeStr[i];
				dictionary[j][1] = '\0';
				length++;
			}
		}

		preDictionaryNum = length;			//先前词典的大小
		return true;
	}
	
	
	void LZWEncode() 	 		 	//LZW 编码过程
	{
		for (int g = 0; g < preDictionaryNum; g++) {	//先前词典中的初始编码没有输出编码，故设置为-1 
			decodeList[g]=-1;
		}

		int num = preDictionaryNum;

		char *q,*p,*c;
		q =  encodeStr;						  	//q为标志指针，用来确认位置的 
		p =  encodeStr; 						//p指针作为字符串匹配的首字符 
		c = p;									//通过不断移动c指针实现匹配 

		while(p-q != strlen(encodeStr)){		//若还没匹配完所有字符，则循环 
			int index=0;
			for (int i = 0; dictionary[i][0] != '\0' && c - q != strlen(encodeStr); i++) {//通过不断向后移动c指针实现匹配
				char temp[N]; 
				strncpy_s(temp,p,c-p+1);			//每添加一个匹配字符，则已匹配字符串temp增加一个字符 
				temp[c-p+1]='\0';
				if(strcmp(temp,dictionary[i]) == 0){//字符匹配成功 
					c++;
					index = i;
				}
			}
			decodeList[num++]=index;			//遇到一个不匹配的字符或者已经没有字符可以匹配，则输出已匹配的字符串 

			if(c-q != strlen(encodeStr)){			//若到一个不匹配的字符且还有字符未匹配，则说明出现了新的词典字段，加入词典 
				strncpy_s(dictionary[length],p,c-p+1);
				dictionary[length][c-p+1]='\0';
				length++;
			}

			p = c;								//匹配下一个时，p指向c的指向 
		}

	} 
	
	
	void LZWDecode()    			//LZW 译码过程 
	{
		for (int i = 1; decodeList[i] != -1; i++) { // 若译码数组不为空
			if(decodeList[i] <= length){				
				strcpy_s(dictionary[length],dictionary[decodeList[i-1]-1]); //若出现输入代码在先前词典可以找到，则输出 ：上一个输出 + 当前输出的第一个 
				char temp[2]; //输出一个字符
				strncpy_s(temp,dictionary[decodeList[i]-1],1);   // 当前输出的第一个 
				temp[1]='\0';
				strcat_s(dictionary[length],temp); //新加入词典
			}
			else{									    
				strcpy_s(dictionary[length],dictionary[decodeList[i-1]-1]); //若出现输入代码在先前词典找不到，则输出 ：上一个输出 + 上一个输出的第一个 
				char temp[2];
				strncpy_s(temp,dictionary[decodeList[i-1]-1],1); // 上一个输出的第一个 
				temp[1]='\0';
				strcat_s(dictionary[length],temp); //新加入词典
			}
			length++;
		}
	}	
};
 
 
int main(){

	while(true){
		cout  <<  "\n\t1.编码\t\t2.译码\t\t(按任意其他键退出)\n\n";
		cout  <<  "请选择:";

		int x;
		cin  >>  x;

		LZW lzw;

		if(x==1){
			cout << "请输入要编码的字符串:" << endl << endl;
			cin >> lzw.encodeStr;

			if(lzw.initDictionary()==false){
				cout << "请正确设置要编码的字符串" << endl;
			}

			lzw.LZWEncode();	//开始编码

			cout << endl << "编码过程为:" << endl << endl;
			cout << "\t码字\t\t\t词典\t\t\t输出" << endl;

			for(int i=0;i<lzw.length;i++){
				cout << "\t" << i + 1 << "\t\t\t" << lzw.dictionary[i] << "\t\t\t";
				if(i >= lzw.preDictionaryNum){
					cout << lzw.decodeList[i] + 1;
				}
				cout << endl;
			}
			cout << "\t-\t\t\t-\t\t\t" << lzw.decodeList[lzw.length] + 1 << endl << endl << endl;
		} 
		else if(x==2){
			cout << "请按顺序输入初始先前词典：（例：1 A）(输入0结束)" << endl;
			int tempNum;
			cin >> tempNum;
			int index = 1; 

			while(tempNum != 0){
				if(tempNum < 0){
					cout << "输入序号错误,重新输入该行" << endl << endl;
					getchar();  //删除已经输入的字符 
					getchar();
					cin >> tempNum;
					continue;
				}
				if(tempNum!=index){
					cout << "请按顺序输入序号,重新输入该行" << endl << endl;
					getchar();
					getchar();
					cin >> tempNum;
					continue;
				}
				cin >> lzw.dictionary[tempNum - 1];
				cin >> tempNum;
				index++; 
			}

			lzw.preDictionaryNum = index-1;
			lzw.length = lzw.preDictionaryNum; 
			
			cout << endl << "请输入要译的编码(输入0结束):" << endl << endl;
			int temp;
			int j=0;
			cin >> temp;

			while(temp!=0){
				if(temp<0){
					cout << "输入要译的编码错误,重新输入该编码" << endl << endl;
					cin >> temp;
					continue;
				}

				lzw.decodeList[j] = temp;
				j++;
				cin >> temp;
			}

			lzw.LZWDecode();	//开始译码 
			cout << endl << "译码过程为:" << endl << endl;
			
			cout << "    输入代码\t\t码字\t\t词典\t\t输出" << endl;
			for(int i=0;i<lzw.preDictionaryNum;i++){
				cout << "      \t\t\t   " << i + 1 << "  \t\t " << lzw.dictionary[i] << endl;
			}

			cout << "\t" << lzw.decodeList[0] << "\t\t   -\t\t -\t\t  " << lzw.dictionary[lzw.decodeList[0] - 1] << endl;

			for(int i=1;lzw.decodeList[i]!=-INT_MAX;i++){
				cout << "\t" << lzw.decodeList[i] << "\t\t   " << i + 3 << "  \t\t " << lzw.dictionary[i + 3 - 1] << "\t\t  " << lzw.dictionary[lzw.decodeList[i] - 1] << endl;
			}

			// 输入代码 对应于 词典内容 

			cout << endl << endl;
		}
		else{
			break;
		} 
	}
	return 0;
}