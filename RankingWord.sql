DECLARE
    
    v_string        VARCHAR2(100) := 'NOTICE';
    v_sort_string   VARCHAR2(100);
    v_cum_string    VARCHAR2(100) := '';
    v_rank          NUMBER := 0;
    v_ctr           NUMBER := 0;
    v_temp_char     VARCHAR2(1);
    v_print_all     boolean;

    FUNCTION factorial(in_number NUMBER) RETURN NUMBER
    IS
        tot        number := 1;
    BEGIN
        
        FOR i in 1..in_number
        LOOP
            tot := tot * i;
        END LOOP;
        
        RETURN tot;
        
    END factorial;    
BEGIN
    v_print_all := false;
    DBMS_OUTPUT.PUT_LINE('Original String: ' || v_string);
    -- Sort the characters of the string alphabetically.
    SELECT REPLACE(MAX(SYS_CONNECT_BY_PATH(txt,'|')), '|') TEXT INTO v_sort_string
    FROM   (SELECT   SUBSTR (txt, lvl, 1) txt
                   , ROW_NUMBER() OVER ( ORDER BY SUBSTR (txt, lvl, 1)) lvl
            FROM     (SELECT     txt
                               , LEVEL lvl
                      FROM       (SELECT v_string txt
                                  FROM   DUAL)
                      CONNECT BY LEVEL <= LENGTH (txt))
            ORDER BY 1)
    CONNECT BY lvl = PRIOR lvl + 1
    START WITH lvl = 1;
    
    DBMS_OUTPUT.PUT_LINE('The String after arranging the letters alphabetically: ' || v_sort_string);
    
    LOOP
        LOOP
            v_ctr := v_ctr + 1;
            v_temp_char := SUBSTR(v_sort_string, v_ctr, 1);
            EXIT WHEN INSTR(v_string, v_cum_string || v_temp_char, 1) = 1;
            v_rank := v_rank + factorial(LENGTH(v_string) - LENGTH(v_cum_string || v_temp_char));
        END LOOP;
        
        v_cum_string := v_cum_string || v_temp_char;
        DBMS_OUTPUT.PUT_LINE('v_cum_string: ' || v_cum_string || ',  v_rank: ' || v_rank);
        -- Remove the characters of v_cum_string from v_sort_string to process the remaining
        FOR i in 1..LENGTH(v_cum_string)
        LOOP
            v_sort_string := REPLACE(v_sort_string, SUBSTR(v_cum_string, i, 1));
        END LOOP i;
        
        EXIT WHEN v_sort_string IS NULL OR TRIM(v_sort_string) = '' OR v_cum_string = v_string;
        v_ctr := 0;
    END LOOP;
    v_rank := v_rank + 1;
    DBMS_OUTPUT.PUT_LINE('Rank: ' || v_rank);
END;
/