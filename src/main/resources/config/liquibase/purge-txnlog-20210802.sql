delete from transaction_log_custom where trl_id in (select trl_id from transaction_log where TRL_SYSTEM_TIMESTAMP >= TO_DATE('20210701 00:00:00', 'YYYYMMDD HH24:MI:SS'));
delete from transaction_log where TRL_SYSTEM_TIMESTAMP >= TO_DATE('20210701 00:00:00', 'YYYYMMDD HH24:MI:SS');
