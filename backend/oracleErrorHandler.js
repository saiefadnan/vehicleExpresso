const errorMessages = {
  'ORA-00001': 'Already exists',
  'ORA-02291': 'Parent ID not found',
  'ORA-02292': 'Child record found',
  'ORA-02290': 'Check constraint violation',
  'ORA-02289': 'Sequence does not exist',
  'ORA-02288': 'Invalid or missing directory',
  'ORA-02287': 'Sequence number not allowed here',
  'ORA-02286': 'No options specified for ALTER SEQUENCE',
  'ORA-02285': 'Duplicate or conflicting attributes',
  'ORA-02284': 'Duplicate keys found',
  'ORA-02283': 'Cannot drop column from table',
  'ORA-02282': 'Missing or invalid option',
  'ORA-02281': 'Invalid ALTER INDEX option',
  'ORA-02280': 'duplicate or conflicting number',
  'ORA-02279': 'duplicate or conflicting scope',
  'ORA-02278': 'invalid INITIAL storage option value',
  'ORA-02277': 'invalid MAXEXTENTS value',
  'ORA-02276': 'invalid STORAGE option',
  'ORA-02275': 'invalid RENAME option',
  'ORA-02274': 'name in FROM list not found in SELECT list',
  'ORA-02273': 'invalid option for ALTER SESSION',
  'ORA-02272': 'invalid INITRANS option value',
  'ORA-02271': 'invalid STORAGE option value',
  'ORA-02270': 'no options specified for ALTER TABLE',
  'ORA-02269': 'no attributes or column specified',
  'ORA-02268': 'cannot just rename a column',
  'ORA-02267': 'column type incompatible with existing columns',
  'ORA-02266':
    'unique/primary keys in table referenced by enabled foreign keys',
  'ORA-02265': 'cannot have virtual columns in key-preserved table',
  'ORA-02264': 'name already used by an existing constraint',
  'ORA-02263': 'need to specify the datatype for this column',
  'ORA-02262': 'duplicate or conflicting NOT NULL constraints',
  'ORA-02261': 'such unique or primary key already exists in the table',
  'ORA-02260': 'table can have only one primary key',
  'ORA-02259': 'duplicate or conflicting NOT NULL and ENABLE/DISABLE options',
  'ORA-02258': 'invalid ALTER TABLE option',
  'ORA-02257': 'cannot alter a cluster table',
  'ORA-02256': 'invalid option for ALTER CLUSTER',
  'ORA-02255': 'cannot use storage options',
  'ORA-02254': 'missing or invalid column constraint',
  'ORA-02253': 'constraint specification not allowed here',
  'ORA-02252': 'missing or invalid table name',
  'ORA-02251': 'subquery not allowed here',
  'ORA-02250': 'missing or invalid constraint name',
  'ORA-02249': 'missing or invalid option for ALTER INDEX',
  'ORA-02248': 'invalid option for ALTER INDEX',
  'ORA-02247': 'missing or invalid schema element',
  'ORA-02246': 'missing COLLATE keyword',
  'ORA-02245': 'invalid ROLLBACK SEGMENT name',
  'ORA-02244': 'invalid ALTER ROLLBACK SEGMENT option',
  'ORA-02243': 'invalid ALTER ROLLBACK SEGMENT name',
  'ORA-02242': 'no options specified for ALTER INDEX',
  'ORA-02241': 'cannot change to cluster key',
  'ORA-02240': 'invalid value for SESSION parameter',
  'ORA-02239': 'cannot validate (string) - no tables to validate',
  'ORA-02238': 'cannot maintain (string) - table has enabled triggers',
  'ORA-02237': 'invalid file size in clause',
  'ORA-02236': 'invalid file name',
  'ORA-02235': 'this table logs changes to another table already',
  'ORA-02234': 'changes to this table will not be logged',
  'ORA-02233': 'cannot create LOGGING/NOLOGGING in this tablespace',
  'ORA-02232': 'missing storage option',
  'ORA-02231': 'missing or invalid option to ALTER DATABASE',
  'ORA-02230': 'invalid ALTER DATABASE option',
  'ORA-02229': 'invalid SIZE option value',
  'ORA-02228': 'invalid SIZE option',
  'ORA-02227': 'invalid MAXEXTENTS option value',
  'ORA-02226': 'missing or invalid option for ALTER SESSION',
  'ORA-02225': 'missing or invalid option for ALTER SYSTEM',
  'ORA-02224': 'EXECUTE privilege not allowed for object',
  'ORA-02223': 'invalid OPTIMAL value',
  'ORA-02222': 'invalid PCTINCREASE storage option value',
  'ORA-02221': 'invalid INITRANS option value',
  'ORA-02220': 'missing or invalid schema element',
  'ORA-02219': 'invalid NEXT storage option value',
  'ORA-02218': 'invalid INITIAL storage option value',
  'ORA-02217': 'duplicate storage option specification',
  'ORA-02216': 'tablespace name not allowed',
  'ORA-02215': 'duplicate tablespace name',
  'ORA-02214': 'duplicate BACKUP option',
  'ORA-02213': 'invalid PCTFREE option value',
  'ORA-02212': 'duplicate or conflicting ORDER options',
  'ORA-02211': 'invalid value for TABLESPACE option',
  'ORA-02210': 'no options specified for ALTER INDEX',
  'ORA-00942': 'Table or view does not exist',
}

const oracleErrorHandler = (error, res) => {
  const errorCode = error.code
  res
    .status(400)
    .json({ error: errorMessages[errorCode] || 'Something went wrong' })
}

module.exports = oracleErrorHandler
