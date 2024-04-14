#include <iostream>
#include <stack>
#include <string>
#include <cmath>

using namespace std;

int precedence(char op)
{
   if (op == '^')
      return 3;
   if (op == '*' || op == '/')
      return 2;
   if (op == '+' || op == '-')
      return 1;
   return 0;
}

double applyOp(double a, double b, char op)
{
   switch (op)
   {
   case '+':
      return a + b;
   case '-':
      return a - b;
   case '*':
      return a * b;
   case '/':
      return a / b;
   case '^':
      return pow(a, b);
   default:
      return 0;
   }
}

double factorial(double n)
{
   if (n <= 1)
      return 1;
   return n * factorial(n - 1);
}

double evaluate(string expression)
{
   stack<double> values;
   stack<char> ops;

   for (int i = 0; i < expression.length(); i++)
   {
      if (expression[i] == ' ')
         continue;
      else if (isdigit(expression[i]))
      {
         double val = 0;
         while (i < expression.length() && isdigit(expression[i]))
         {
            val = val * 10 + (expression[i] - '0');
            i++;
         }
         values.push(val);
         i--;
      }
      else if (expression[i] == '(')
      {
         ops.push(expression[i]);
      }
      else if (expression[i] == ')')
      {
         while (!ops.empty() && ops.top() != '(')
         {
            double val2 = values.top();
            values.pop();
            double val1 = values.top();
            values.pop();
            char op = ops.top();
            ops.pop();
            values.push(applyOp(val1, val2, op));
         }
         ops.pop();
      }
      else
      {
         while (!ops.empty() && precedence(ops.top()) >= precedence(expression[i]))
         {
            double val2 = values.top();
            values.pop();
            double val1 = values.top();
            values.pop();
            char op = ops.top();
            ops.pop();
            values.push(applyOp(val1, val2, op));
         }
         ops.push(expression[i]);
      }
   }

   while (!ops.empty())
   {
      double val2 = values.top();
      values.pop();
      double val1 = values.top();
      values.pop();
      char op = ops.top();
      ops.pop();
      values.push(applyOp(val1, val2, op));
   }

   return values.top();
}

int main()
{
   string expression = "10 + 2 * 6";
   cout << "Result: " << evaluate(expression) << endl;

   expression = "100 * 2 + 12";
   cout << "Result: " << evaluate(expression) << endl;

   expression = "100 * ( 2 + 12 ) / 14";
   cout << "Result: " << evaluate(expression) << endl;

   expression = "5^2 + 4!";
   cout << "Result: " << evaluate(expression) << endl;

   return 0;
}
