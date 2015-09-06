#include <iostream>
#include <string>
using namespace std;

int IsRight(string card);
bool BirthdayIsRight(string cardId);
bool NameIsRight(string name);
int GetDay(int year,int month);

int IsRight(string card)
{
	int error=0;
	int length=(int)card.length();
	int index=card.find_first_not_of("1234567890X");
	if(index!=(int)card.npos)
	{
		error=-1;  //号码中有非数字字符
	}else
	{
		if(!BirthdayIsRight(card))
		{
			error=-4; //出生年月错误
		}else
		{
			if(length==18)     //验证18位身份证号码
			{
				int no[]={7,9,10,5,8,4,2,1,6,3,7,9,10,5,8,4,2};
				char id[]={'1','0','X','9','8','7','6','5','4','3','2'};

				const char *p=card.c_str();
				int i=0,wi=0,sum=0;
				for(;i<length-1;i++)
				{
					wi=(*(p+i)-'0')*no[i];
					sum+=wi;
				}
				if(*(p+i)<'0'||*(p+i)>'9')
				{
					if (*(p+i)!='X'&&*(p+i)!='x')
					{
						error=-2;//身份证最后一位输入错误
						return error;
					}
				}
				wi=sum%11;
				if(*(p+17)=='x'||*(p+17)=='X')            //最后一位为'x'或'X';
				{
					if(id[wi]!='x'&&id[wi]!='X')
						error=-3;
				}
				else if(id[wi]!=*(p+17))     //判断计算出的身份证校验码与输入是否相符
				{
					error=-3;
				}
			}
		}
	}
	return error;
}
//判断身份证号码中的年月日是否正确
bool BirthdayIsRight(string cardId)
{
	string year,month,day;
	time_t tt = time(nullptr);
	tm * p_tm = gmtime(&tt);

	bool flag=false;
	int length=cardId.length();
	if(length==18)
	{
		year=cardId.substr(6,4);//取18位身份证中的年
		if( (1900+p_tm->tm_year)-atoi(year.c_str())<18 )	//不满18岁
			return false;
		month=cardId.substr(10,2); // 月
		day=cardId.substr(12,2);   //日
	}
	else
	{
		year=cardId.substr(6,2);//取15位身份证中的年
		if( p_tm->tm_year-atoi(year.c_str())<18 )	//不满18岁
			return false;
		month=cardId.substr(8,2); // 月
		day=cardId.substr(10,2);   //日
		year="19"+year;
	}
	//
	if(atoi(year.c_str())==0||atoi(month.c_str())==0||atoi(day.c_str())==0)
	{
		flag=false;
	}
	else if(GetDay(atoi(year.c_str()),atoi(month.c_str()))>=atoi(day.c_str()))
	{
		flag=true;
	}
	return flag;
}
//得到指定年跟月的天数
int GetDay(int year, int month)
{
	int day=0;
	switch (month)
	{
	case 1:
	case 3:
	case 5:
	case 7:
	case 8:
	case 10:
	case 12:
		{
			day=31;
			break;
		}
	case 4:
	case 6:
	case 9:
	case 11:
		{
			day=30;
			break;
		}
	case 2:
		{
			if( (year%4==0&&year%100!=0) || year%400==0 )
				day=29;
			else
				day=28;
			break;
		}
	default:
		{
			day=-1;
			break;
		}
	}
	return day;
}
bool NameIsRight(string name)
{
	// utf8
	int name_len = name.length();
	if( name_len%3 != 0 )
		return false;
	for(int i=0; i<name_len; i+=3 )
	{
		if( name.at(i) > 0 )
			return false;
	}
	return true;
}
