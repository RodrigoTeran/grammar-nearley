@{%
  const { lexer } = require("./lexer");
%}

@lexer lexer

statements
  -> statement
      {%
        (data) => {
          return [data[0]];
        }
      %}
    | statements %NL statement
      {%
        (data) => {
          return [...data[0], data[2]];
        }
      %}

statement
  -> input_assign               {% id %}
  | fun_call                    {% id %}
  | var_assign                  {% id %}
  | task_function               {% id %}
  | comments                    {% id %}
  | if_statement                {% id %}
  | while_loop                  {% id %}
  | for_loop                    {% id %}
  | elseIf_statement            {% id %}
  | else_statement              {% id %}  
  | _                           {% id %}


statementsFunction
  -> statementFunction
      {%
        (data) => {
          return [data[0]];
        }
      %}
    | statementsFunction %NL statementFunction
      {%
        (data) => {
          return [...data[0], data[2]];
        }
      %}

statementsOperators
  -> statementOperator
      {%
        (data) => {
          return [data[0]];
        }
      %}
    | statementsOperators %NL statementOperator
      {%
        (data) => {
          return [...data[0], data[2]];
        }
      %}

statementFunction
  -> _ fun_call
    {%
      (data) => {
        return data[1];
      }
    %}  
  | _ var_assign
    {%
      (data) => {
        return data[1];
      }
    %}    
  | comments                    {% id %}
  | _ if_statement
    {%
      (data) => {
        return data[1];
      }
    %} 
  | _ while_loop
    {%
      (data) => {
        return data[1];
      }
    %}
  | _ for_loop
    {%
      (data) => {
        return data[1];
      }
    %} 
  | _ elseIf_statement
    {%
      (data) => {
        return data[1];
      }
    %}
  | _ else_statement
    {%
      (data) => {
        return data[1];
      }
    %}     
  | _ task_function
    {%
      (data) => {
        return data[1];
      }
    %}  
  | _ "return" _ %thickArrow _ (expr_return):? _
    {%
      (data) => {
        return {
          type: "return",
          value: data[5] ? data[5][0] : false
        }
      }
    %}  
  | _                             {% id %}


statementOperator
  -> _ fun_call
    {%
      (data) => {
        return data[1];
      }
    %}
  | _ var_assign
    {%
      (data) => {
        return data[1];
      }
    %}
  | comments                    {% id %}
  | _ if_statement
    {%
      (data) => {
        return data[1];
      }
    %}
  | _ while_loop
    {%
      (data) => {
        return data[1];
      }
    %}
  | _ for_loop
    {%
      (data) => {
        return data[1];
      }
    %}
  | _ elseIf_statement
    {%
      (data) => {
        return data[1];
      }
    %}
  | _ else_statement
    {%
      (data) => {
        return data[1];
      }
    %}    
  | _ task_function
    {%
      (data) => {
        return data[1];
      }
    %}
  | _                             {% id %}


input_assign
  -> %identifier _ %assign _ input_fun _
    {%
      (data) => {
        return {
          type: "input_assign",
          var_name: data[0],
          value: data[4],
        }
      }
    %}

input_fun
  -> "ask" %lparen _ (%string | %string2 | %identifier | %number _):? %rparen
    {%
      (data) => {
        return {
          type: "input_fun",
          input: data[3] ? data[3][0] : "",
        }
      }
    %}

fun_call
  -> %identifier %lparen _ (arg_list _):? %rparen _
    {%
      (data) => {
        return {
          type: "fun_call",
          fun_name: data[0],
          arguments: data[3] ? data[3][0] : [],
        }
      }
    %}

var_assign
  -> %identifier _ %assign _ expr _
      {%
        (data) => {
          return {
            type: "var_assign",
            var_name: data[0],
            value: data[4],
          }
        }
      %}

task_function -> "task" _ %arrow _ %identifier %lparen _ (param_list _):? %rparen _ task_body _
  {%
    (data) => {
      return {
        type: "task",
        parameters: data[7] ? data[7][0] : [],
        body: data[10],
        identifierName: data[4],
      }
    }
  %}

while_loop -> "period" _ %arrow comparisonsNearley operators_body _
  {%
    (data) => {
      return {
        type: "whileLoop",
        comparisons: data[3],
        body: data[4],
      }
    }
  %}

for_loop -> "from" _ %arrow for_looping_options operators_body _
  {%
    (data) => {
      return {
        type: "forLoop",
        options: data[3],
        body: data[4],
      }
    }
  %}

if_statement -> "assuming" _ %arrow comparisonsNearley operators_body _
  {%
    (data) => {
      return {
        type: "ifStatement",
        comparisons: data[3],
        body: data[4],
      }
    }
  %}

elseIf_statement -> "differentAssumption" _ %arrow comparisonsNearley operators_body _
  {%
    (data) => {
      return {
        type: "elseIfStatement",
        comparisons: data[3],
        body: data[4],
      }
    }
  %}

else_statement -> "different" _ %arrow _ operators_body _
  {%
    (data) => {
      return {
        type: "elseStatement",
        body: data[4],
      }
    }
  %}

operators_body
  ->  %lbrace _ %NL statementsOperators %NL _ %rbrace _
    {%
      (data) => {
        return data[3];
      }
    %}

comments -> _ %comment _ 
  {%
    (data) => {
      return {
        type: "comment"
      }
    }
  %}

task_body
  ->  %lbrace _ %NL statementsFunction %NL _ %rbrace _
    {%
      (data) => {
          return data[3];
      }
    %}

arg_list
  -> expr
    {%
      (data) => {
        return [data[0]];
      }
    %}
  | arg_list __ expr
    {%
      (data) => {
        return [...data[0], data[2]];
      }
    %}

param_list
  -> %identifier
    {%
      (data) => {
        return [data[0]];
      }
    %}
  | param_list __ %identifier
    {%
      (data) => {
        return [...data[0], data[2]];
      }
    %}

list
  -> %lbracket _ (arg_list _):? %rbracket _
    {%
      (data) => {
        return {
          type: "array",
          arguments: data[2] ? data[2][0] : [],
        };
      }
    %}

item_list
  -> %identifier %lbracket _ (%number | %identifier):? %rbracket _
    {%
      (data) => {
        return {
          type: "array_item",
          array_name: data[0],
          item: data[3] ? data[3][0] : [],
        };
      }
    %}

expr
  -> %string         {% id %}
  | %string2         {% id %}
  | item_list        {% id %}
  | "WIN"
      {%
        (data) => {
          return {
            type: "true",
            value: true
          };
        }
      %}
  | "FAIL"
      {%
        (data) => {
          return {
            type: "false",
            value: false
          };
        }
      %}
  | %number          {% id %}
  | %identifier      {% id %}
  | fun_call         {% id %}
  | list             {% id %}

expr_return
  -> %string         {% id %}
  | %string2         {% id %}
  | item_list        {% id %}
  | "WIN"
      {%
        (data) => {
          return {
            type: "true",
            value: true
          };
        }
      %}
  | "FAIL"
      {%
        (data) => {
          return {
            type: "false",
            value: false
          };
        }
      %}
  | %number          {% id %}
  | %identifier      {% id %}
  | list             {% id %}
    
booleanOperators
  -> "and"
      {%
        (data) => {
          return {
            type: "booleanOperator",
            value: "and"
          };
        }
      %}
  | "or"
      {%
        (data) => {
          return {
            type: "booleanOperator",
            value: "or"
          };
        }
      %}


noupBooleanOperator -> "noup"
  {%
    (data) => {
      return {
        type: "booleanOperator",
        value: "noup"
      };
    }
  %}


logicOperators
  -> %equal                    {% id %}
  | %notEqual                  {% id %}
  | %greaterEqualThan          {% id %}
  | %lowerEqualThan            {% id %}
  | %greaterThan               {% id %}
  | %lowerThan                 {% id %}


comparison
  -> (noupBooleanOperator __):? expr __ logicOperators __ expr
    {%
      (data) => {
        return {
          type: "comparison",
          firstExpr: data[1],
          secondExpr: data[5],
          logic: data[3],
          withNoup: data[0] ? true : false
        };
      }
    %}

comparisons
  -> comparison
    {% 
      (data) => {
        return [data[0]];
      }
    %}
  | comparisons __ booleanOperators __ comparison
    {%
      (data) => {
        return [...data[0], data[2], data[4]]
      }
    %}

comparisonsNearley -> _ comparisons _
    {%
      (data) => {
        return {
          type: "comparisons",
          value: data[1]
        }
      }
    %}

for_looping_options -> _ expr __ "to" __ expr __ "with" __ %identifier _
  {%
    (data) => {
      return {
        type: "forOptions",
        from: data[1],
        to: data[5],
        variable: data[9]
      }
    }
  %}


# Optional whitespace
_ -> %WS:*
      {%
        (data) => {
          return {
            type: "empty_line",
          }
        }
      %}

# Mandatory whitespace
__ -> %WS:+