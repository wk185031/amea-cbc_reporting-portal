CREATE OR REPLACE FUNCTION GetSupportApprDate(CLobInput VARCHAR2) RETURN DATE DETERMINISTIC IS
       V_DATE           DATE;
       NoOfChar         NUMBER;
       V_SUBSTR_DESC    VARCHAR2(50);
       V_INSTR          INTEGER;
       V_SUBSTR         VARCHAR2(10);
       V_NTH            NUMBER;
BEGIN
        V_NTH:=2;
        V_SUBSTR_DESC:=REGEXP_INSTR(CLobInput,'COMPLETED',1,1);
        IF V_SUBSTR_DESC > 0 THEN
            V_NTH:=1;
        END IF;
 
        V_INSTR:= REGEXP_INSTR(CLobInput,'DATE',1,V_NTH);
        IF V_INSTR > 0 THEN
            V_INSTR:=V_INSTR+7;
        END IF;
        V_SUBSTR:=SUBSTR(CLobInput,V_INSTR,10);
        IF V_SUBSTR IS NOT NULL THEN
        V_DATE:=TO_DATE(V_SUBSTR,'YYYY-MM-DD');
        END IF;
        RETURN V_DATE;
END ;
/