#include <iostream>
#include <stack>
#include <string>
#include <cmath>

using namespace std;

int fact[37];
double preAns = 0;

bool validOps(char c) {
   return c == '+' || c == '-' || c == '*' || c == '/' || c == '^' || c == '!';
}

int precedence(char op) {
   if (op == '+' || op == '-')
      return 1;
   if (op == '*' || op == '/')
      return 2;
   if (op == '^')
      return 3;
   if (op == '!')
      return 4;
   return 0; 
}

string int_to_string(int n) {
   string str = "";
   while (n) {
      str = char(n % 10 + '0') + str;
      n /= 10;
   }
   return str;
}

int validateString(string &expr) {
   int balance = 0;
   for (int i = 0; i < expr.length(); i++) {
      if (expr[i] == 'M') {
         if (i > 0 && (isdigit(expr[i - 1]) || expr[i - 1] == ')')) {
            expr.insert(i++, "*");
         }
         else if (i + 1 < expr.length() && (isdigit(expr[i + 1]) || expr[i + 1] == '.')) {
            return 4; // syntax error near 'M' character
         }
         expr.erase(i, 1);
         expr.insert(i, to_string(preAns));
         i += int_to_string(preAns).length() - 1;
      }
      else if (expr[i] == ' ')
         expr.erase(i, 1);
      else if (expr[i] == '.') {
         if (i + 1 == expr.length() || !isdigit(expr[i + 1]) || i == 0 || !isdigit(expr[i - 1]))
            return 2; // syntax error: invalid '.' character
      }
      else if (expr[i] == '(' ) {
         if (i != 0 && (expr[i - 1] == ')' || isdigit(expr[i - 1]) || expr[i - 1] == '!')) {
            expr.insert(i++, "*");
         }
         balance++;
      } 
      else if (expr[i] == ')') {
         if (i + 1 < expr.length() && isdigit(expr[i + 1])) {
            expr.insert(++i, "*");
         }
         if (balance == 0) {
            return 0; // parentheses error
         }
         balance--;
      }
      else if (expr[i] == '-') {
         bool minus = true;
         while(i + 1 < expr.length()) {
            if (expr[i + 1] == '+') {
               expr.erase(i + 1, 1);
            }
            else if (expr[i + 1] == '-') {
               minus = !minus;
               expr.erase(i + 1, 1);
            }
            else
               break;
         }
         expr[i] = (minus)? '-' : '+';
      }
      else if (expr[i] == '+') {
         if (i + 1 < expr.length() && (expr[i + 1] == '+' || expr[i + 1] == '-'))
            expr.erase(i--, 1);
      }
      else if (expr[i] == '!') {
         if (i + 1 < expr.length() && (isdigit(expr[i + 1]) || expr[i + 1] == '!')) {
            return 3; // syntax error: invalid '!' character
         }
      }
      else if (!validOps(expr[i]) && !isdigit(expr[i])) {
         return 1; // syntax error: contains invalid character
      }
   }

   if (balance) {
      return 0; // parentheses error
   }
   std::cout << "validated_string: " << expr << '\n';
   return -1;  // valid string
}

string infixToPostfix(const string &expr) {
   stack<char> s;
   string postfix = "";
   bool isNum = false;

   for (int i = 0; i < expr.length(); i++) {
      if (expr[i] == '-' || expr[i] == '+') {
         bool unary = false;
         if (i == 0) {
            unary = true;
         }
         else if (!isdigit(expr[i - 1]) && expr[i - 1] != ')' && expr[i - 1] != '!') {
            unary = true;
         }

         if (unary) {
            if (expr[i] == '-')
               postfix += '-';
            i++;
         }
      }
      else if (expr[i] == '.') {
         postfix += ".";
         i++;
      }

      if (isdigit(expr[i])) {
         postfix += expr[i];
         isNum = true;
      } 
      else if (expr[i] == '(') {
         s.push('(');
      } 
      else if (expr[i] == ')') {
         if (isNum) {
            postfix += " ";
            isNum = false;
         }
         while (!s.empty() && s.top() != '(') {
            postfix += s.top();
            postfix += " ";
            s.pop();
         }
         s.pop();
      } 
      else if (validOps(expr[i])) {
         if (isNum) {
            postfix += " ";
            isNum = false;
         }
         while (!s.empty() && precedence(s.top()) >= precedence(expr[i])) {
            postfix += s.top();
            postfix += " ";
            s.pop();
         }
         s.push(expr[i]);
      }
   }
   while (!s.empty()) {
      postfix += " ";
      postfix += s.top();
      s.pop();
   }
   return postfix;
}

double postfixExp(string& str, int& invalid) {
   stack<double> s;
   bool isNegative = false;
   for (int i = 0; i < str.length(); i++) {
      if (str[i] == ' ')
         continue;

      if (str[i] == '-' && isdigit(str[i + 1])) {
         isNegative = true;
         i++;
      }

      if (isdigit(str[i])) {
         double val = 0;
         double fraction = 0;
         while (i < str.length() && isdigit(str[i])) {
            val = val * 10 + (str[i] - '0');
            i++;
         }
         if (str[i] == '.') {
            i++;
            double k = 10;
            while (i < str.length() && isdigit(str[i])) {
               fraction += (str[i] - '0') / k;
               k *= 10;
               i++;
            }
         }
         i--;
         val += fraction;
         if (isNegative) {
            val *= -1;
            isNegative = false;
         }
         s.push(val);
      } 
      else {
         // invalid
         if (s.empty()) {
            invalid = 1;
            return -1;
         }

         double val1 = s.top();
         s.pop();

         if (str[i] == '!') {
            if (val1 < 0) {
               invalid = 2; // syntax error: factorial of negative number
               return -1;
            }
            if (val1 > 36) {
               invalid = 3; // math error: factorial is too large to calculate
               return -1;
            }
            if (val1 != (int)val1) {
               invalid = 4; // syntax error: factorial of non-integer number
               return -1;
            }
            s.push(fact[(int)val1]);
            continue;
         }

         // invalid
         if (s.empty()) {
            invalid = 1;
            return -1;
         }

         double val2 = s.top();
         s.pop();
         switch (str[i]) {
            case '+':
               s.push(val2 + val1);
               break;
            case '-':
               s.push(val2 - val1);
               break;
            case '*':
               s.push(val2 * val1);
               break;
            case '/':
               if (val1 == 0) {
                  invalid = 5; // math error: division by 0
                  return -1;
               }
               s.push(val2 / val1);
               break;
            case '^':
               s.push(pow(val2, val1));
               break;
         }
      }
   }
   if (s.size() != 1) {
      invalid = 1;   // syntax error: invalid operation
      return -1;
   }

   return s.top();
}

int main()
{
   for (int i = 0; i < 36; i++)
   {
      if (i <= 1)
         fact[i] = 1;
      else
         fact[i] = i * fact[i - 1];
   }

   std::cout << "Please insert your expression: ";
   string expr;

   while (true)
   {
      std::cout << "\n>> ";
      std::getline(std::cin, expr);
      if (expr == "")
         continue;

      if (expr == "quit")
      {
         std::cout << "EXIT!" << endl;
         return 0;
      }

      // convert infix to postfix
      int invalid = 0;
      int valid = validateString(expr);
      if (valid == 0) {
         std::cout << "PARENTHESIS ERROR!" << '\n';
         continue;
      }
      else if (valid == 1) {
         std::cout << "SYNTAX ERROR: CONTAINING INVALID CHARACTER!" << '\n';
         continue;
      }
      else if (valid == 2) {
         std::cout << "SYNTAX ERROR: INVALID '.' CHARACTER!" << '\n';
         continue;
      }
      else if (valid == 3) {
         std::cout << "SYNTAX ERROR: INVALID '!' CHARACTER!" << '\n';
         continue;
      }
      else if (valid == 4) {
         std::cout << "SYNTAX ERROR NEAR 'M' CHARACTER!" << '\n';
         continue;
      }


      string exp = infixToPostfix(expr);
      double res = postfixExp(exp, invalid);
      std::cout << "exp: " << exp << '\n';
      // calculate postfix expr
      if (invalid == 1) {
         std::cout << "SYNTAX ERROR: INVALID OPERATION!" << '\n';
         continue;
      }
      else if (invalid == 2) {
         std::cout << "MATH ERROR: FACTORIAL OF NON-POSITIVE NUMBER!" << '\n';
         continue;
      }
      else if (invalid == 3) {
         std::cout << "MATH ERROR: FACTORIAL IS TOO LARGE TO CALCULATE!" << '\n';
         continue;
      }
      else if (invalid == 4) {
         std::cout << "MATH ERROR: FACTORIAL OF NON-INTEGER NUMBER!" << '\n';
         continue;
      }
      else if (invalid == 5) {
         std::cout << "MATH ERROR: DIVISION BY ZERO!" << '\n';
         continue;
      }
      std::cout << "res: " << res << '\n';
      preAns = res;
   }
}