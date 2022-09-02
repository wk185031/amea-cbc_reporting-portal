drop function GetApprDate;

CREATE OR REPLACE FUNCTION GetApprDate(CLobInput VARCHAR2) RETURN DATE DETERMINISTIC IS
       V_DATE           DATE;
       NoOfChar         NUMBER;
       V_SUBSTR_DESC    VARCHAR2(50);
       V_INSTR          INTEGER;
       V_SUBSTR         VARCHAR2(10);
       V_NTH            NUMBER;
BEGIN
        V_NTH:=1;
        V_SUBSTR_DESC:=REGEXP_INSTR(CLobInput,'Request\s\w+\sApproved',1,1);
        IF V_SUBSTR_DESC > 0 THEN
            V_NTH:=2;
        END IF;
 
        V_INSTR:= REGEXP_INSTR(CLobInput,'date',1,V_NTH);
        IF V_INSTR > 0 THEN
            V_INSTR:=V_INSTR+7;
			V_SUBSTR:=SUBSTR(CLobInput,V_INSTR,8);
        END IF;
        IF V_SUBSTR IS NOT NULL THEN
        V_DATE:=TO_DATE(V_SUBSTR,'DD-MM-YY');
        END IF;
        RETURN V_DATE;
END ;
/