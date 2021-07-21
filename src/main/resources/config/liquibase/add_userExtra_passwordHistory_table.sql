CREATE TABLE PASSWORD_HISTORY
   (
    "ID" NUMBER(38,0) GENERATED ALWAYS AS IDENTITY, 
	"PASSWORD_HASH" VARCHAR2(60 BYTE),
	"PASSWORD_CHANGE_TS" TIMESTAMP(6),
	CONSTRAINT "PASSWORD_HISTORY_PK" PRIMARY KEY ("ID")
	) TABLESPACE AUTH_REPORT_DATA_TS;

CREATE TABLE USER_EXTRA_PASSWORD_HISTORY
   (
    "PASSWORD_HISTORY_ID" NUMBER(38,0) NOT NULL ENABLE, 
	"USER_EXTRA_ID" NUMBER(38,0) NOT NULL ENABLE, 
	 CONSTRAINT "USER_EXTRA_PASSWORD_HISTORY_PK" PRIMARY KEY ("USER_EXTRA_ID", "PASSWORD_HISTORY_ID"),
	 CONSTRAINT "FK_USER_EXTRA_PASSWORD_HISTORY_USER_EXTRA_ID" FOREIGN KEY ("USER_EXTRA_ID") REFERENCES USER_EXTRA(ID),
	 CONSTRAINT "FK_USER_EXTRA_PASSWORD_HISTORY_PASSWORD_HISTORY_ID" FOREIGN KEY ("PASSWORD_HISTORY_ID") REFERENCES PASSWORD_HISTORY(ID)
	) TABLESPACE AUTH_REPORT_DATA_TS;