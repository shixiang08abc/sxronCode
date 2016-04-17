#include<iostream>
using namespace std;

void solvePLA(float (*data)[2],int label[])
{
	int dim = 2;
	double ratio = 0.1;
	double w[] = {0,0,0};
	bool isError = true;
	int count = 0;
	while(isError)
	{
		isError = false;
		for(int n=0;n<3;n++)
		{
			double sum = w[0];
			for(int m=0;m<dim;m++)
				sum += w[m+1]* data[n][m];
				
			int predict = 0;
			if(sum>0)
			{
				predict = 1;
			}
			else if(sum<0)
			{
				predict = -1;
			}
			if(predict!=label[n])
			{
				w[0] = w[0] + label[n]*ratio;
				for(int i=0;i<dim;i++)
				{
					w[i+1] = w[i+1] +label[n]*data[n][i]*ratio;
				}
				count++;
				isError = true;
				n--;
			}
		}
	}	
	cout<<"count:"<<count<<endl;
	cout<<"w:"<<w[0]<<"\t"<<w[1]<<"\t"<<w[2]<<endl;
}

int main()
{
	float data[3][2] = {{3,3},{4,3},{1,1}};
	int label[] = {1,1,-1};
	
	solvePLA(data,label);
	
	return 0;
}