CREATE TABLE PRODUCTS (
    PRODUCT_ID NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    PRODUCT_NAME VARCHAR2(100 CHAR) NOT NULL,
    PRODUCT_DESCRIPTION VARCHAR2(1000 CHAR) NOT NULL,
    PRODUCT_IMAGE_URL VARCHAR2(2048 CHAR) NOT NULL,
    PRODUCT_CATEGORY VARCHAR2(100 CHAR) NOT NULL,
    CREATED_AT DATE DEFAULT SYSDATE,
    SELLER_ID NUMBER NOT NULL,
    SELLER_PRICE NUMBER(10, 2) NOT NULL,
    SELLER_STOCK NUMBER(10) NOT NULL,
    STATUS NUMBER(1) DEFAULT 1,
    CONSTRAINT FK_USER FOREIGN KEY (SELLER_ID) REFERENCES USERS(USERID)
);

CREATE TABLE PURCHASES (
    PURCHASE_ID NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    BUYER_ID NUMBER NOT NULL,
    PAYMENT_OPTION VARCHAR2(50 CHAR) CHECK (PAYMENT_OPTION IN ('Cash', 'Bkash', 'Card')),
    PURCHASE_DATE DATE DEFAULT SYSDATE,
    PROMO_CODE VARCHAR2(100 CHAR),
    TOTAL_PRICE NUMBER(10, 2) NOT NULL,
    CONSTRAINT FK_USER FOREIGN KEY (BUYER_ID) REFERENCES USERS(USERID),
    CONSTRAINT FK_PROMO_CODE FOREIGN KEY (PROMO_CODE) REFERENCES PROMOCODES(PROMO_CODE)
);

CREATE TABLE PURCHASE_DETAILS (
    PURCHASE_ID NUMBER NOT NULL,
    PRODUCT_ID NUMBER NOT NULL,
    ITEM_PRICE NUMBER(10, 2) NOT NULL,
    QUANTITY NUMBER(10) NOT NULL,
    DISCOUNT_PRICE NUMBER(10, 2),
    TOTAL_PRICE AS ((QUANTITY * ITEM_PRICE) - NVL(DISCOUNT_PRICE, 0)),
    CONSTRAINT PK_PURCHASE_DETAILS PRIMARY KEY (PURCHASE_ID, PRODUCT_ID),
    CONSTRAINT FK_PURCHASE FOREIGN KEY (PURCHASE_ID) REFERENCES PURCHASES(PURCHASE_ID),
    CONSTRAINT FK_PRODUCT FOREIGN KEY (PRODUCT_ID) REFERENCES PRODUCTS(PRODUCT_ID)
);

CREATE VIEW PURCHASES_WITH_DETAILS AS
    SELECT
        P.PURCHASE_ID,
        P.BUYER_ID,
        P.PAYMENT_OPTION,
        P.PURCHASE_DATE,
        P.PROMO_CODE,
        P.TOTAL_PRICE                                                                AS PURCHASE_TOTAL_PRICE,
        LISTAGG( 'Product ID: '
                 || PD.PRODUCT_ID
                 || ', Item Price: '
                 || PD.ITEM_PRICE
                 || ', Quantity: '
                 || PD.QUANTITY
                 || ', Discount Price: '
                 || NVL(PD.DISCOUNT_PRICE, 0)
                    || ', Total Price: '
                    || PD.TOTAL_PRICE, ' | ' ) WITHIN GROUP (ORDER BY PD.PRODUCT_ID) AS PRODUCT_DETAILS
    FROM
        PURCHASES        P
        JOIN PURCHASE_DETAILS PD
        ON P.PURCHASE_ID = PD.PURCHASE_ID
    GROUP BY
        P.PURCHASE_ID,
        P.BUYER_ID,
        P.PAYMENT_OPTION,
        P.PURCHASE_DATE,
        P.PROMO_CODE,
        P.TOTAL_PRICE;

CREATE TABLE CARD_PAYMENTS (
    PURCHASE_ID NUMBER PRIMARY KEY,
    CARD_TYPE VARCHAR2(20 CHAR) NOT NULL,
    CARD_HOLDER_NAME VARCHAR2(100 CHAR) NOT NULL,
    CARD_NUMBER VARCHAR2(20 CHAR) NOT NULL,
    CARD_EXPIRY_DATE DATE NOT NULL,
    CARD_CVV VARCHAR2(4 CHAR) NOT NULL,
    CONSTRAINT FK_CARD_PAYMENT_PURCHASE FOREIGN KEY (PURCHASE_ID) REFERENCES PURCHASES(PURCHASE_ID)
);

CREATE TABLE BKASH_PAYMENTS (
    PURCHASE_ID NUMBER PRIMARY KEY,
    BKASH_ACCOUNT VARCHAR2(20 CHAR) NOT NULL,
    CONSTRAINT FK_BKASH_PAYMENT_PURCHASE FOREIGN KEY (PURCHASE_ID) REFERENCES PURCHASES(PURCHASE_ID)
);

CREATE TABLE PRODUCTREVIEWS (
    REVIEW_ID NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    USER_ID NUMBER NOT NULL,
    PRODUCT_ID NUMBER NOT NULL,
    RATING NUMBER(1) NOT NULL,
    REVIEW_TEXT VARCHAR2(1000 CHAR),
    REVIEW_DATE DATE DEFAULT SYSDATE,
    CONSTRAINT FK_USER_REVIEW FOREIGN KEY (USER_ID) REFERENCES USERS(USERID),
    CONSTRAINT FK_PRODUCT_REVIEW FOREIGN KEY (PRODUCT_ID) REFERENCES PRODUCTS(PRODUCT_ID)
);

CREATE TABLE PRODUCTQUESTIONS (
    QUESTION_ID NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    PRODUCT_ID NUMBER NOT NULL,
    BUYER_ID NUMBER NOT NULL,
    QUESTION_TEXT VARCHAR2(1000 CHAR) NOT NULL,
    QUESTION_DATE DATE DEFAULT SYSDATE,
    CONSTRAINT FK_PRODUCT_QUESTION FOREIGN KEY (PRODUCT_ID) REFERENCES PRODUCTS(PRODUCT_ID),
    CONSTRAINT FK_USER_QUESTION FOREIGN KEY (BUYER_ID) REFERENCES USERS(USERID)
);

CREATE TABLE PRODUCTANSWERS (
    ANSWER_ID NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    QUESTION_ID NUMBER NOT NULL,
    SELLER_ID NUMBER NOT NULL,
    ANSWER_TEXT VARCHAR2(1000 CHAR) NOT NULL,
    ANSWER_DATE DATE DEFAULT SYSDATE,
    CONSTRAINT FK_QUESTION_ANSWER FOREIGN KEY (QUESTION_ID) REFERENCES PRODUCTQUESTIONS(QUESTION_ID),
    CONSTRAINT FK_USER_ANSWER FOREIGN KEY (SELLER_ID) REFERENCES USERS(USERID)
);

CREATE TABLE PRODUCTREPORTS (
    REPORT_ID NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    PRODUCT_ID NUMBER NOT NULL,
    USER_ID NUMBER NOT NULL,
    REPORT_TEXT VARCHAR2(1000 CHAR) NOT NULL,
    REPORT_DATE DATE DEFAULT SYSDATE,
    CONSTRAINT FK_PRODUCT_REPORT FOREIGN KEY (PRODUCT_ID) REFERENCES PRODUCTS(PRODUCT_ID),
    CONSTRAINT FK_USER_REPORT FOREIGN KEY (USER_ID) REFERENCES USERS(USERID)
);

CREATE TABLE PROMOCODES (
    PROMO_CODE VARCHAR2(100 CHAR) NOT NULL PRIMARY KEY,
    START_DATE DATE NOT NULL,
    END_DATE DATE NOT NULL,
    DISCOUNT_PERCENTAGE NUMBER(5, 2) NOT NULL,
    MAX_DISCOUNT NUMBER(10, 2) NOT NULL
);

INSERT INTO PROMOCODES (
    PROMO_CODE,
    START_DATE,
    END_DATE,
    DISCOUNT_PERCENTAGE,
    MAX_DISCOUNT
) VALUES (
    'WEEKEND',
    TO_DATE('2024-01-01', 'YYYY-MM-DD'),
    TO_DATE('2024-12-31', 'YYYY-MM-DD'),
    5,
    500
);

SELECT
    PQ.QUESTION_ID,
    PQ.PRODUCT_ID,
    PQ.QUESTION_TEXT,
    PQ.QUESTION_DATE,
    PA.ANSWER_TEXT,
    PA.ANSWER_DATE,
    BUYER.NAME       AS BUYER_NAME,
    SELLER.NAME      AS SELLER_NAME
FROM
    PRODUCTQUESTIONS PQ,
    PRODUCTANSWERS   PA,
    USERS            BUYER,
    USERS            SELLER
WHERE
    PQ.QUESTION_ID = PA.QUESTION_ID
    AND PQ.PRODUCT_ID = 377488764
    AND BUYER.USERID = PQ.BUYER_ID
    AND SELLER.USERID = PA.SELLER_ID
ORDER BY
    PQ.QUESTION_DATE DESC;

SELECT
    PQ.QUESTION_ID,
    (
        SELECT
            PA.QUESTION_ID
        FROM
            PRODUCTANSWERS PA
        WHERE
            PA.QUESTION_ID = PQ.QUESTION_ID
    ) AS ANSWER_ID,
    PQ.PRODUCT_ID,
    PQ.QUESTION_TEXT,
    PQ.QUESTION_DATE,
    (
        SELECT
            PA.ANSWER_TEXT
        FROM
            PRODUCTANSWERS PA
        WHERE
            PA.QUESTION_ID = PQ.QUESTION_ID
    ) AS ANSWER_TEXT,
    (
        SELECT
            PA.ANSWER_DATE
        FROM
            PRODUCTANSWERS PA
        WHERE
            PA.QUESTION_ID = PQ.QUESTION_ID
    ) AS ANSWER_DATE,
    (
        SELECT
            NAME
        FROM
            USERS
        WHERE
            USERID = PQ.BUYER_ID
    ) AS BUYER_NAME,
    (
        SELECT
            NAME
        FROM
            USERS
        WHERE
            USERID = (
                SELECT
                    SELLER_ID
                FROM
                    PRODUCTANSWERS PA
                WHERE
                    PA.QUESTION_ID = PQ.QUESTION_ID
            )
    ) AS SELLER_NAME
FROM
    PRODUCTQUESTIONS PQ
WHERE
    PQ.PRODUCT_ID = :PRODUCTID
ORDER BY
    PQ.QUESTION_DATE DESC;

CREATE OR REPLACE PROCEDURE UPDATE_STATUS(
    P_PRODUCT_ID IN NUMBER
) AS
BEGIN
    UPDATE PRODUCTS
    SET
        STATUS = CASE WHEN STATUS = 0 THEN 1 ELSE 0 END
    WHERE
        PRODUCT_ID = P_PRODUCT_ID;
END;

CREATE OR REPLACE PROCEDURE GET_SALES( P_SELLER_ID IN NUMBER, SEARCH_TERM IN VARCHAR2 DEFAULT NULL, SALES_CURSOR OUT SYS_REFCURSOR ) AS
BEGIN
    OPEN SALES_CURSOR FOR
        SELECT
            P.PRODUCT_ID,
            P.PRODUCT_NAME,
            P.PRODUCT_DESCRIPTION,
            P.PRODUCT_CATEGORY,
            P.PRODUCT_IMAGE_URL,
            P.SELLER_STOCK,
            SUM(PD.QUANTITY)                AS TOTAL_QUANTITY,
            PD.ITEM_PRICE,
            SUM(PD.DISCOUNT_PRICE)          AS TOTAL_DISCOUNT,
            SUM(PD.TOTAL_PRICE)             AS TOTAL_PRICE,
            P.STATUS,
            MAX(PUR.PURCHASE_DATE)          AS LAST_PURCHASE_DATE,
            SUM(SUM(PD.TOTAL_PRICE)) OVER() AS TOTAL_SALES
        FROM
            PRODUCTS         P,
            PURCHASE_DETAILS PD,
            PURCHASES        PUR
        WHERE
            P.PRODUCT_ID = PD.PRODUCT_ID
            AND PD.PURCHASE_ID = PUR.PURCHASE_ID
            AND P.SELLER_ID = P_SELLER_ID
            AND (SEARCH_TERM IS NULL
            OR LOWER(P.PRODUCT_NAME) LIKE '%'
                                          || LOWER(SEARCH_TERM)
                                          || '%')
        GROUP BY
            P.PRODUCT_ID,
            P.PRODUCT_NAME,
            P.PRODUCT_DESCRIPTION,
            P.PRODUCT_CATEGORY,
            P.PRODUCT_IMAGE_URL,
            PD.ITEM_PRICE,
            P.SELLER_STOCK,
            P.STATUS
        ORDER BY
            LAST_PURCHASE_DATE DESC;
END;