
--================================================================================================================================
DECLARE @PERIODO VARCHAR(8)

SET @PERIODO='202110'

--================================================================================================================================

--DROP TABLE #CUENTAS

SELECT A.IdTercero,A.Cod_Terc,GT.CodTipoDoc,CASE WHEN CodTipoDoc='CC' THEN 0 ELSE G.dig_veri END AS dig_veri,G.NomTercero,Cod_Cuen,
ROUND(SUM(A.ValorSaldoNiif),0) AS SALDO
INTO #CUENTAS
FROM cnt_Cuen_Sald A
LEFT JOIN genTercero G ON G.IdTercero=A.IdTercero AND G.NumDocumento=A.Cod_Terc
LEFT JOIN genTipoDoc GT ON GT.IdTipoDoc=G.IdTipoDoc
WHERE A.Per_sald=@PERIODO
AND A.Cod_Cuen LIKE '6%'
GROUP BY  A.IdTercero,A.Cod_Terc,A.Cod_Cuen,GT.CodTipoDoc,G.dig_veri,G.NomTercero
--===========================================================================================================================================
--DROP TABLE #INFOPRE1
SELECT DISTINCT IdTercero,Cod_Terc,dig_veri,NomTercero,CONVERT(money,0) AS COSPOSFAC,CONVERT(money,0) AS FACGLO,CONVERT(money,0) AS GLOPPTMAX,
CONVERT(money,0) AS COSNOPOS,CONVERT(money,0) AS COSPREMAX,CONVERT(money,0) AS FACRADSAU,CONVERT(money,0) AS VARAUTGEN,CONVERT(money,0) AS VARCONCAPPGP,
CONVERT(money,0) AS VARPREMAXGEN,CONVERT(money,0) AS OTRCOS,CONVERT(money,0) AS COSINC,CONVERT(money,0) AS RESNOCON,CONVERT(money,0) AS RESPPTMAX,CONVERT(money,0) AS TOTAL
INTO #INFOPRE1 
FROM #CUENTAS
--SE CALCULA EL COSTO POS FACTURACION
	WHERE Cod_Cuen IN ('6102010101','6102010102','6102010103','6102010104','6102010105','6102010106','6102010107','6102010108','6102010109','6102010110',
	'6102010111','6102010112','6102010114','6102010115','6102010116','6102010117','6102010118','6102010119','6102010120','6102010121','6102010125',
	'6102010127','6102010201','6102010202','6102010203','6102010204','6102010205','6102010206','6102010207','6102010208','6102010209','6102010210',
	'6102010211','6102010212','6102010214','6102010215','6102010216','6102010217','6102010218','6102010219','6102010220','6102010221','6102010225',
	'6102010227','6102130101','6102130103','6102130201','6102140101','6102140102','6102140103','6102140104','6102140106','6102140107','6102140109',
	'6102140110','6102140111','6102140112','6102140113','6102140201','6102140202','6102140203','6102140204','6102140205'
	--FACTURAS GLOSADAS
	,'6102070103','6102070203'
	--GLOSADAS PPTO MAXIMO 
	,'6103070103','6103070203'
	--COSTO NO POS 
	,'6103020101','6103020103','6103020104','6103020111','6103020118','6103020120','6103020125','6103020127','6103020227'
	--COSTO PRESUPUESTO MAXIMO 
	,'6103060101','6103060103','6103060104','6103060111','6103060114','6103060116','6103060120','6103060125','6103060126'
	,'6103060127','6103060203','6103060204','6103060211','6103060214','6103060216','6103060225','6103060226','6103060227','6103060201'
	--FACTURAS RADICADAS SIN AUDITAR 
	,'6102070102','6102070201'
	--VARIACION PROVISION AUTORIZACIONES GENERADAS     
	,'6102070101'
	-- VARIACION PROVISIÓN DEL MES  PARA LOS CONTRATOS DE  CAPITA Y PGP  
	,'6102070104','6102070204'
	--VARIACION PROVISION PRESUPUESTO MAXIMO GENERADAS 
	,'6103070101','6103070201')

--===========================================================================================================================================
--SE CALCULA EL COSTO POS FACTURACION
UPDATE A
SET COSPOSFAC=B.SALDO
--SELECT *
FROM #INFOPRE1 A
INNER JOIN 
	( SELECT IdTercero,Cod_Terc,ROUND(SUM(SALDO),0) AS SALDO
	FROM #CUENTAS
	WHERE Cod_Cuen IN ('6102010101','6102010102','6102010103','6102010104','6102010105','6102010106','6102010107','6102010108','6102010109','6102010110',
	'6102010111','6102010112','6102010114','6102010115','6102010116','6102010117','6102010118','6102010119','6102010120','6102010121','6102010125',
	'6102010127','6102010201','6102010202','6102010203','6102010204','6102010205','6102010206','6102010207','6102010208','6102010209','6102010210',
	'6102010211','6102010212','6102010214','6102010215','6102010216','6102010217','6102010218','6102010219','6102010220','6102010221','6102010225',
	'6102010227','6102130101','6102130103','6102130201','6102140101','6102140102','6102140103','6102140104','6102140106','6102140107','6102140109',
	'6102140110','6102140111','6102140112','6102140113','6102140201','6102140202','6102140203','6102140204','6102140205')
	GROUP BY IdTercero,Cod_Terc
	) AS B ON B.IdTercero=A.IdTercero AND B.Cod_Terc=A.Cod_Terc
GO
--===========================================================================================================================================
--FACTURAS GLOSADAS
UPDATE A
SET FACGLO=B.SALDO
--SELECT *
FROM #INFOPRE1 A
INNER JOIN
( 
    SELECT IdTercero,Cod_Terc,ROUND(SUM(SALDO),0) AS SALDO
	FROM #CUENTAS
	WHERE Cod_Cuen IN ('6102070103','6102070203')
	GROUP BY IdTercero,Cod_Terc
) AS B ON B.IdTercero=A.IdTercero AND B.Cod_Terc=A.Cod_Terc
GO
--===========================================================================================================================================
--GLOSADAS PPTO MAXIMO 
UPDATE A
SET GLOPPTMAX=B.SALDO
--SELECT *
FROM #INFOPRE1 A
INNER JOIN
( 
    SELECT IdTercero,Cod_Terc,ROUND(SUM(SALDO),0) AS SALDO
	FROM #CUENTAS
	WHERE Cod_Cuen IN ('6103070103','6103070203')
	GROUP BY IdTercero,Cod_Terc
) AS B ON B.IdTercero=A.IdTercero AND B.Cod_Terc=A.Cod_Terc
GO
--===========================================================================================================================================
--COSTO NO POS 
UPDATE A
SET COSNOPOS=B.SALDO
--SELECT *
FROM #INFOPRE1 A
INNER JOIN
( 
    SELECT IdTercero,Cod_Terc,ROUND(SUM(SALDO),0) AS SALDO
	FROM #CUENTAS
	WHERE Cod_Cuen IN ('6103020101','6103020103','6103020104','6103020111','6103020118','6103020120','6103020125','6103020127','6103020227')
	GROUP BY IdTercero,Cod_Terc
) AS B ON B.IdTercero=A.IdTercero AND B.Cod_Terc=A.Cod_Terc
GO
--===========================================================================================================================================
--COSTO PRESUPUESTO MAXIMO 
UPDATE A
SET COSPREMAX=B.SALDO
--SELECT *
FROM #INFOPRE1 A
INNER JOIN
( 
    SELECT IdTercero,Cod_Terc,ROUND(SUM(SALDO),0) AS SALDO
	FROM #CUENTAS
	WHERE Cod_Cuen IN ('6103060101','6103060103','6103060104','6103060111','6103060114','6103060116','6103060120','6103060125','6103060126'
,'6103060127','6103060203','6103060204','6103060211','6103060214','6103060216','6103060225','6103060226','6103060227','6103060201')
	GROUP BY IdTercero,Cod_Terc
) AS B ON B.IdTercero=A.IdTercero AND B.Cod_Terc=A.Cod_Terc
GO
--===========================================================================================================================================
--FACTURAS RADICADAS SIN AUDITAR 
UPDATE A
SET FACRADSAU=B.SALDO
--SELECT *
FROM #INFOPRE1 A
INNER JOIN
( 
    SELECT IdTercero,Cod_Terc,ROUND(SUM(SALDO),0) AS SALDO
	FROM #CUENTAS
	WHERE Cod_Cuen IN ('6102070102','6102070201')
	GROUP BY IdTercero,Cod_Terc
) AS B ON B.IdTercero=A.IdTercero AND B.Cod_Terc=A.Cod_Terc
GO
--===========================================================================================================================================
--VARIACION PROVISION AUTORIZACIONES GENERADAS     
UPDATE A
SET VARAUTGEN=B.SALDO
--SELECT *
FROM #INFOPRE1 A
INNER JOIN
( 
    SELECT IdTercero,Cod_Terc,ROUND(SUM(SALDO),0) AS SALDO
	FROM #CUENTAS
	WHERE Cod_Cuen IN ('6102070101')
	GROUP BY IdTercero,Cod_Terc
) AS B ON B.IdTercero=A.IdTercero AND B.Cod_Terc=A.Cod_Terc
GO
--===========================================================================================================================================
-- VARIACION PROVISIÓN DEL MES  PARA LOS CONTRATOS DE  CAPITA Y PGP  
UPDATE A
SET VARCONCAPPGP=B.SALDO
--SELECT *
FROM #INFOPRE1 A
INNER JOIN
( 
    SELECT IdTercero,Cod_Terc,ROUND(SUM(SALDO),0) AS SALDO
	FROM #CUENTAS
	WHERE Cod_Cuen IN ('6102070104','6102070204')
	GROUP BY IdTercero,Cod_Terc
) AS B ON B.IdTercero=A.IdTercero AND B.Cod_Terc=A.Cod_Terc
GO
--===========================================================================================================================================
--VARIACION PROVISION PRESUPUESTO MAXIMO GENERADAS 
UPDATE A
SET VARPREMAXGEN=B.SALDO
--SELECT *
FROM #INFOPRE1 A
INNER JOIN
( 
    SELECT IdTercero,Cod_Terc,ROUND(SUM(SALDO),0) AS SALDO
	FROM #CUENTAS
	WHERE Cod_Cuen IN ('6103070101','6103070201')
	GROUP BY IdTercero,Cod_Terc
) AS B ON B.IdTercero=A.IdTercero AND B.Cod_Terc=A.Cod_Terc
GO
--===========================================================================================================================================
--OTROS COSTOS
INSERT INTO #INFOPRE1 (IdTercero,Cod_Terc,dig_veri,NomTercero,COSPOSFAC,FACGLO,GLOPPTMAX,COSNOPOS,COSPREMAX,FACRADSAU,VARAUTGEN,
VARCONCAPPGP,VARPREMAXGEN,OTRCOS,COSINC,RESNOCON,RESPPTMAX,TOTAL)
SELECT '','','','',0,0,0,0,0,0,0,0,0,SALDO,0,0,0,0
FROM 
(
SELECT ROUND(SUM(SALDO),0) AS SALDO
FROM #CUENTAS
WHERE Cod_Cuen LIKE ('610215%')
) AS A

UPDATE #INFOPRE1
SET COSINC=(SELECT ROUND(SUM(SALDO),0) AS SALDO FROM #CUENTAS WHERE Cod_Cuen LIKE ('610202%')) + (SELECT ROUND(SUM(SALDO),0) AS SALDO FROM #CUENTAS WHERE Cod_Cuen LIKE ('610208%'))
FROM #INFOPRE1
WHERE IdTercero=''

UPDATE #INFOPRE1
SET RESNOCON=(SELECT ROUND(SUM(SALDO),0) AS SALDO FROM #CUENTAS WHERE Cod_Cuen LIKE ('610210%')) + (SELECT ROUND(SUM(SALDO),0) AS SALDO FROM #CUENTAS WHERE Cod_Cuen LIKE ('610211%'))
FROM #INFOPRE1
WHERE IdTercero=''


--===========================================================================================================================================
--GENERAR INFORME
--===========================================================================================================================================

SELECT Cod_Terc,dig_veri,NomTercero,COSPOSFAC,FACGLO,GLOPPTMAX,COSNOPOS,COSPREMAX,FACRADSAU,VARAUTGEN,
VARCONCAPPGP,VARPREMAXGEN,OTRCOS,COSINC,RESNOCON,RESPPTMAX,
(COSPOSFAC+FACGLO+GLOPPTMAX+COSNOPOS+COSPREMAX+FACRADSAU+VARAUTGEN+VARCONCAPPGP+VARPREMAXGEN+OTRCOS+COSINC+RESNOCON+RESPPTMAX) AS TOTAL
FROM #INFOPRE1
ORDER BY Cod_Terc DESC

