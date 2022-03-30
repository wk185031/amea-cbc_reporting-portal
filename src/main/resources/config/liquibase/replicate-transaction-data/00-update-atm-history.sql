-- This script is use to update the invalid ASH_AST_ID to reference to a correct value.
-- 1. Find and repalce <T-day-date> in YYYY-MM-DD format
-- 2. Disable the constraint in table atm_status_history before executing this script
-- 3. Import the dump
-- 4. Execute this script to update the correct reference
-- 5.Enable the constraint

update atm_status_history set ash_ast_id=(select ast_id from atm_stations where ast_terminal_id='10031034') where ash_ast_id not in (select ast_id from atm_stations);
update atm_status_history set ash_timestamp = TO_TIMESTAMP('<T-day-date> 22:22:22', 'YYYY-MM-DD HH24:MI:SS') where ash_seq_nmbr > 1000000;
update atm_txn_activity_log set ata_timestamp=to_timestamp('<T-day-date> 22:22:22', 'YYYY-MM-DD HH24:MI:SS') where ata_timestamp=to_timestamp('2022-03-10 22:22:22', 'YYYY-MM-DD HH24:MI:SS');

commit;