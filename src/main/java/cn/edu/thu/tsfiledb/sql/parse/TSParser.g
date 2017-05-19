parser grammar TSParser;

options
{
tokenVocab=TSLexer;
output=AST;
ASTLabelType=CommonTree;
backtrack=false;
k=3;
}

tokens {

//update
TOK_SHOW_METADATA;
TOK_MERGE;
TOK_QUIT;
TOK_PRIVILEGES;
TOK_USER;
TOK_ROLE;
TOK_CREATE;
TOK_DROP;
TOK_GRANT;
TOK_REVOKE;
TOK_UPDATE;
TOK_VALUE;
TOK_INSERT;
TOK_MULTINSERT;
TOK_QUERY;
TOK_SELECT;
TOK_PASSWORD;
TOK_PATH;
TOK_UPDATE_PSWD;
TOK_FROM;
TOK_WHERE;
TOK_CLUSTER;
TOK_LOAD;
TOK_METADATA;
TOK_NULL;
TOK_ISNULL;
TOK_ISNOTNULL;
TOK_DATETIME;
TOK_DELETE;


/*
  BELOW IS THE METADATA TOKEN
*/
TOK_MULT_VALUE;
TOK_MULT_IDENTIFIER;
TOK_TIME;
TOK_WITH;
TOK_ROOT;
TOK_DATATYPE;
TOK_ENCODING;
TOK_CLAUSE;
TOK_TIMESERIES;
TOK_SET;
TOK_ADD;
TOK_PROPERTY;
TOK_LABEL;
TOK_LINK;
TOK_UNLINK;
TOK_STORAGEGROUP;
TOK_DESCRIBE;
}


@header {
package cn.edu.thu.tsfiledb.sql.parse;

import java.util.Arrays;
import java.util.Collection;
import java.util.HashMap;

}


@members{
ArrayList<ParseError> errors = new ArrayList<ParseError>();
    Stack msgs = new Stack<String>();

    private static HashMap<String, String> xlateMap;
    static {
        //this is used to support auto completion in CLI
        xlateMap = new HashMap<String, String>();

        // Keywords
        xlateMap.put("KW_TRUE", "TRUE");
        xlateMap.put("KW_FALSE", "FALSE");

        xlateMap.put("KW_AND", "AND");
        xlateMap.put("KW_OR", "OR");
        xlateMap.put("KW_NOT", "NOT");
        xlateMap.put("KW_LIKE", "LIKE");

        xlateMap.put("KW_BY", "BY");
        xlateMap.put("KW_GROUP", "GROUP");
        xlateMap.put("KW_WHERE", "WHERE");
        xlateMap.put("KW_FROM", "FROM");

        xlateMap.put("KW_SELECT", "SELECT");
        xlateMap.put("KW_INSERT", "INSERT");

        xlateMap.put("KW_ON", "ON");


        xlateMap.put("KW_SHOW", "SHOW");

        xlateMap.put("KW_CLUSTER", "CLUSTER");

        xlateMap.put("KW_LOAD", "LOAD");

        xlateMap.put("KW_NULL", "NULL");
        xlateMap.put("KW_CREATE", "CREATE");

        xlateMap.put("KW_DESCRIBE", "DESCRIBE");

        xlateMap.put("KW_TO", "TO");

        xlateMap.put("KW_DATETIME", "DATETIME");
        xlateMap.put("KW_TIMESTAMP", "TIMESTAMP");
        
        xlateMap.put("KW_CLUSTERED", "CLUSTERED");

        xlateMap.put("KW_INTO", "INTO");

        xlateMap.put("KW_ROW", "ROW");
        xlateMap.put("KW_STORED", "STORED");
        xlateMap.put("KW_OF", "OF");
        xlateMap.put("KW_ADD", "ADD");
        xlateMap.put("KW_FUNCTION", "FUNCTION");
        xlateMap.put("KW_WITH", "WITH");
        xlateMap.put("KW_SET", "SET");
        xlateMap.put("KW_UPDATE", "UPDATE");
        xlateMap.put("KW_VALUES", "VALUES");
        xlateMap.put("KW_KEY", "KEY");
        xlateMap.put("KW_ENABLE", "ENABLE");
        xlateMap.put("KW_DISABLE", "DISABLE");

        // Operators
        xlateMap.put("DOT", ".");
        xlateMap.put("COLON", ":");
        xlateMap.put("COMMA", ",");
        xlateMap.put("SEMICOLON", ");");

        xlateMap.put("LPAREN", "(");
        xlateMap.put("RPAREN", ")");
        xlateMap.put("LSQUARE", "[");
        xlateMap.put("RSQUARE", "]");

        xlateMap.put("EQUAL", "=");
        xlateMap.put("NOTEQUAL", "<>");
        xlateMap.put("EQUAL_NS", "<=>");
        xlateMap.put("LESSTHANOREQUALTO", "<=");
        xlateMap.put("LESSTHAN", "<");
        xlateMap.put("GREATERTHANOREQUALTO", ">=");
        xlateMap.put("GREATERTHAN", ">");

        xlateMap.put("CharSetLiteral", "\\'");
    }

    public static Collection<String> getKeywords() {
        return xlateMap.values();
    }

    private static String xlate(String name) {

        String ret = xlateMap.get(name);
        if (ret == null) {
            ret = name;
        }

        return ret;
    }

    @Override
    public Object recoverFromMismatchedSet(IntStream input,
                                           RecognitionException re, BitSet follow) throws RecognitionException {
        throw re;
    }

    @Override
    public void displayRecognitionError(String[] tokenNames,
                                        RecognitionException e) {
        errors.add(new ParseError(this, e, tokenNames));
    }

    @Override
    public String getErrorHeader(RecognitionException e) {
        String header = null;
        if (e.charPositionInLine < 0 && input.LT(-1) != null) {
            Token t = input.LT(-1);
            header = "line " + t.getLine() + ":" + t.getCharPositionInLine();
        } else {
            header = super.getErrorHeader(e);
        }

        return header;
    }

    @Override
    public String getErrorMessage(RecognitionException e, String[] tokenNames) {
        String msg = null;

        // Translate the token names to something that the user can understand
        String[] xlateNames = new String[tokenNames.length];
        for (int i = 0; i < tokenNames.length; ++i) {
            xlateNames[i] = TSParser.xlate(tokenNames[i]);
        }

        if (e instanceof NoViableAltException) {
            @SuppressWarnings("unused")
            NoViableAltException nvae = (NoViableAltException) e;
            // for development, can add
            // "decision=<<"+nvae.grammarDecisionDescription+">>"
            // and "(decision="+nvae.decisionNumber+") and
            // "state "+nvae.stateNumber
            msg = "cannot recognize input near"
                    + (input.LT(1) != null ? " " + getTokenErrorDisplay(input.LT(1)) : "")
                    + (input.LT(2) != null ? " " + getTokenErrorDisplay(input.LT(2)) : "")
                    + (input.LT(3) != null ? " " + getTokenErrorDisplay(input.LT(3)) : "");
        } else if (e instanceof MismatchedTokenException) {
            MismatchedTokenException mte = (MismatchedTokenException) e;
            msg = super.getErrorMessage(e, xlateNames) + (input.LT(-1) == null ? "":" near '" + input.LT(-1).getText()) + "'";
        } else if (e instanceof FailedPredicateException) {
            FailedPredicateException fpe = (FailedPredicateException) e;
            msg = "Failed to recognize predicate '" + fpe.token.getText() + "'. Failed rule: '" + fpe.ruleName + "'";
        } else {
            msg = super.getErrorMessage(e, xlateNames);
        }

        if (msgs.size() > 0) {
            msg = msg + " in " + msgs.peek();
        }
        return msg;
    }

    // counter to generate unique union aliases
   

}


@rulecatch {
catch (RecognitionException e) {
 reportError(e);
  throw e;
}
}

// starting rule
statement
	: execStatement EOF
	;

number
    : Integer | Float
    ;

numberOrString // identifier is string or integer
    : identifier | Float
    ;

execStatement
    : authorStatement
    | deleteStatement
    | updateStatement
    | insertStatement
    | queryStatement
    | metadataStatement 
    | mergeStatement
    | quitStatement
    ;



dateFormat
    : LPAREN year = Integer MINUS month = Integer MINUS day = Integer hour = Integer COLON minute = Integer COLON second = Integer COLON mil_second = Integer RPAREN
    -> ^(TOK_DATETIME $year $month $day $hour $minute $second $mil_second)
    ;

dateFormatWithNumber
    : LPAREN year = Integer MINUS month = Integer MINUS day = Integer hour = Integer COLON minute = Integer COLON second = Integer COLON mil_second = Integer RPAREN
    -> ^(TOK_DATETIME $year $month $day $hour $minute $second $mil_second)
    | Integer
    -> Integer
    ;



/*
****
*************
metadata
*************
****
*/


metadataStatement
    : createTimeseries
    | setFileLevel
    | addAPropertyTree
    | addALabelProperty
    | deleteALebelFromPropertyTree
    | linkMetadataToPropertyTree
    | unlinkMetadataNodeFromPropertyTree
    | deleteTimeseries
    | showMetadata
    | describePath
    ;

describePath
    : KW_DESCRIBE path
    -> ^(TOK_DESCRIBE path) 
    ;

showMetadata
  : KW_SHOW KW_METADATA
  -> ^(TOK_SHOW_METADATA) 
  ;

createTimeseries
  : KW_CREATE KW_TIMESERIES timeseries KW_WITH propertyClauses
  -> ^(TOK_CREATE ^(TOK_TIMESERIES timeseries) ^(TOK_WITH propertyClauses))
  ;

timeseries
  : root=Identifier DOT deviceType=Identifier DOT identifier (DOT identifier)+
  -> ^(TOK_ROOT $deviceType identifier+)
  ;

propertyClauses
  : KW_DATATYPE EQUAL propertyName=identifier COMMA KW_ENCODING EQUAL pv=propertyValue (COMMA propertyClause)*
  -> ^(TOK_DATATYPE $propertyName) ^(TOK_ENCODING $pv) propertyClause*
  ;

propertyClause
  : propertyName=identifier EQUAL pv=propertyValue
  -> ^(TOK_CLAUSE $propertyName $pv)
  ;

propertyValue
  : numberOrString
  ;

setFileLevel
  : KW_SET KW_STORAGE KW_GROUP KW_TO path
  -> ^(TOK_SET ^(TOK_STORAGEGROUP path))
  ;

addAPropertyTree
  : KW_CREATE KW_PROPERTY property=identifier
  -> ^(TOK_CREATE ^(TOK_PROPERTY $property))
  ;

addALabelProperty
  : KW_ADD KW_LABEL label=identifier KW_TO KW_PROPERTY property=identifier
  -> ^(TOK_ADD ^(TOK_LABEL $label) ^(TOK_PROPERTY $property))
  ;

deleteALebelFromPropertyTree
  : KW_DELETE KW_LABEL label=identifier KW_FROM KW_PROPERTY property=identifier
  -> ^(TOK_DELETE ^(TOK_LABEL $label) ^(TOK_PROPERTY $property))
  ;

linkMetadataToPropertyTree
  : KW_LINK timeseriesPath KW_TO propertyPath
  -> ^(TOK_LINK timeseriesPath propertyPath)
  ;

timeseriesPath
  : Identifier (DOT identifier)+
  -> ^(TOK_ROOT identifier+)
  ;

propertyPath
  : property=identifier DOT label=identifier
  -> ^(TOK_LABEL $label) ^(TOK_PROPERTY $property) 
  ;

unlinkMetadataNodeFromPropertyTree
  :KW_UNLINK timeseriesPath KW_FROM propertyPath
  -> ^(TOK_UNLINK timeseriesPath  propertyPath)
  ;

deleteTimeseries
  : KW_DELETE KW_TIMESERIES timeseries
  -> ^(TOK_DELETE ^(TOK_TIMESERIES timeseries))
  ;


/*
****
*************
crud & author
*************
****
*/
mergeStatement
    :
    KW_MERGE
    -> ^(TOK_MERGE)
    ;

quitStatement
    :
    KW_QUIT
    -> ^(TOK_QUIT)
    ;

queryStatement
   :
   selectClause
   fromClause?
   whereClause?
   -> ^(TOK_QUERY selectClause fromClause? whereClause?)
   ;

authorStatement
    : loadStatement
    | createUser
    | dropUser
    | createRole
    | dropRole 
    | grantUser
    | grantRole
    | revokeUser 
    | revokeRole 
    | grantRoleToUser
    | revokeRoleFromUser
    ;

loadStatement
    : KW_LOAD KW_TIMESERIES (fileName=StringLiteral) identifier (DOT identifier)*
    -> ^(TOK_LOAD $fileName identifier+)
    ;

createUser
    : KW_CREATE KW_USER
        userName=numberOrString
        password=numberOrString
    -> ^(TOK_CREATE ^(TOK_USER $userName) ^(TOK_PASSWORD $password ))
    ;

dropUser
    : KW_DROP KW_USER userName=identifier
    -> ^(TOK_DROP ^(TOK_USER $userName))
    ;

createRole
    : KW_CREATE KW_ROLE roleName=identifier
    -> ^(TOK_CREATE ^(TOK_ROLE $roleName))
    ;

dropRole
    : KW_DROP KW_ROLE roleName=identifier
    -> ^(TOK_DROP ^(TOK_ROLE $roleName))
    ;

grantUser
    : KW_GRANT KW_USER userName = identifier privileges KW_ON path
    -> ^(TOK_GRANT ^(TOK_USER $userName) privileges path)
    ;

grantRole
    : KW_GRANT KW_ROLE roleName=identifier privileges KW_ON path
    -> ^(TOK_GRANT ^(TOK_ROLE $roleName) privileges path)
    ;

revokeUser
    : KW_REVOKE KW_USER userName = identifier privileges KW_ON path
    -> ^(TOK_REVOKE ^(TOK_USER $userName) privileges path)
    ;

revokeRole
    : KW_REVOKE KW_ROLE roleName = identifier privileges KW_ON path
    -> ^(TOK_REVOKE ^(TOK_ROLE $roleName) privileges path)
    ;

grantRoleToUser
    : KW_GRANT roleName = identifier KW_TO userName = identifier
    -> ^(TOK_GRANT ^(TOK_ROLE $roleName) ^(TOK_USER $userName))
    ;

revokeRoleFromUser
    : KW_REVOKE roleName = identifier KW_FROM userName = identifier
    -> ^(TOK_REVOKE ^(TOK_ROLE $roleName) ^(TOK_USER $userName))
    ;

privileges
    : KW_PRIVILEGES StringLiteral (COMMA StringLiteral)*
    -> ^(TOK_PRIVILEGES StringLiteral+)
    ;

path
    : nodeName (DOT nodeName)*
      -> ^(TOK_PATH nodeName+)
    ;

nodeName
    : identifier
    | STAR
    ;
    
insertStatement
   : KW_INSERT KW_INTO path multidentifier KW_VALUES multiValue
   -> ^(TOK_MULTINSERT path multidentifier multiValue)
   ;

/*
Assit to multinsert, target grammar:  insert into root.<deviceType>.<deviceName>(time, s1 ,s2) values(timeV, s1V, s2V)
*/

multidentifier
	:
	LPAREN KW_TIMESTAMP (COMMA identifier)* RPAREN
	-> ^(TOK_MULT_IDENTIFIER TOK_TIME identifier*)
	;
multiValue
	:
	LPAREN time=dateFormatWithNumber (COMMA number)* RPAREN
	-> ^(TOK_MULT_VALUE $time number*)
	;


deleteStatement
   :
   KW_DELETE KW_FROM path (whereClause)? 
   -> ^(TOK_DELETE path whereClause?)
   ;

updateStatement
   : KW_UPDATE path KW_SET KW_VALUE EQUAL value=number (whereClause)?
   -> ^(TOK_UPDATE path ^(TOK_VALUE $value) whereClause?)
   | KW_UPDATE KW_USER userName=StringLiteral KW_SET KW_PASSWORD psw=StringLiteral
   -> ^(TOK_UPDATE ^(TOK_UPDATE_PSWD $userName $psw))
   ;

/*
****
*************
Basic Blocks
*************
****
*/


identifier
    :
    Identifier | Integer
    ;

selectClause
    : KW_SELECT path (COMMA path)*
    -> ^(TOK_SELECT path+)
    | KW_SELECT clstcmd = identifier LPAREN path RPAREN (COMMA clstcmd=identifier LPAREN path RPAREN)*
    -> ^(TOK_SELECT ^(TOK_CLUSTER path $clstcmd)+ )
    ;

clusteredPath
	: clstcmd = identifier LPAREN path RPAREN
	-> ^(TOK_PATH path ^(TOK_CLUSTER $clstcmd) )
	| path
	-> path
	;

fromClause
    :
    KW_FROM path (COMMA path)* -> ^(TOK_FROM path+)
    ;


whereClause
    :
    KW_WHERE searchCondition -> ^(TOK_WHERE searchCondition)
    ;

searchCondition
    :
    expression
    ;

expression
    :
    precedenceOrExpression
    ;

precedenceOrExpression
    :
    precedenceAndExpression ( KW_OR^ precedenceAndExpression)*
    ;

precedenceAndExpression
    :
    precedenceNotExpression ( KW_AND^ precedenceNotExpression)*
    ;

precedenceNotExpression
    :
    (KW_NOT^)* precedenceEqualExpressionSingle
    ;


precedenceEqualExpressionSingle
    :
    (left=atomExpression -> $left)
    (
    	(precedenceEqualOperator equalExpr=atomExpression)
       -> ^(precedenceEqualOperator $precedenceEqualExpressionSingle $equalExpr)
    )*
    ;


precedenceEqualOperator
    :
    EQUAL | EQUAL_NS | NOTEQUAL | LESSTHANOREQUALTO | LESSTHAN | GREATERTHANOREQUALTO | GREATERTHAN
    ;



nullCondition
    :
    KW_NULL -> ^(TOK_ISNULL)
    | KW_NOT KW_NULL -> ^(TOK_ISNOTNULL)
    ;



atomExpression
    :
    (KW_NULL) => KW_NULL -> TOK_NULL
    | (constant) => constant
    | path
    | LPAREN! expression RPAREN!
    ;

constant
    : number
    | StringLiteral
    | dateFormat
    ;
