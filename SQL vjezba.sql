-- 1. 
DELIMITER $$
CREATE TRIGGER ai_stavka_smanji
AFTER INSERT ON stavke_narudzbe
FOR EACH ROW
BEGIN
    UPDATE proizvod
    SET kolicina = kolicina - NEW.kolicina
    WHERE proizvodId = NEW.proizvodId;
END$$
DELIMITER ;


-- 2. 
DELIMITER $$
CREATE TRIGGER bu_proizvod_kolicina
BEFORE UPDATE ON proizvod
FOR EACH ROW
BEGIN
    IF NEW.kolicina < 0 THEN
        SET NEW.kolicina = 0;
    END IF;
END$$
DELIMITER ;


-- 3. 
DELIMITER $$
CREATE TRIGGER bd_zaposlenik
BEFORE DELETE ON zaposlenik
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT * FROM kupac
        WHERE zaposlenikId = OLD.zaposlenikId
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Zaposlenik ima kupce';
    END IF;
END$$
DELIMITER ;


-- 4. 
DELIMITER $$
CREATE PROCEDURE povecaj_placu(IN z_id INT)
BEGIN
    IF (SELECT placa FROM zaposlenik WHERE zaposlenikId = z_id) < 5000 THEN

        UPDATE zaposlenik
        SET placa = placa * 1.10
        WHERE zaposlenikId = z_id;

        SELECT 'Povecanje 10%';

    ELSEIF (SELECT placa FROM zaposlenik WHERE zaposlenikId = z_id) <= 7000 THEN

        UPDATE zaposlenik
        SET placa = placa * 1.05
        WHERE zaposlenikId = z_id;

        SELECT 'Povecanje 5%';

    ELSE

        UPDATE zaposlenik
        SET placa = placa * 1.02
        WHERE zaposlenikId = z_id;

        SELECT 'Povecanje 2%';

    END IF;

    SELECT placa FROM zaposlenik WHERE zaposlenikId = z_id;
END$$
DELIMITER ;


-- 5. 
DELIMITER $$

CREATE PROCEDURE kupci_drzava(IN k_drzava VARCHAR(50))
BEGIN

    SELECT 
        k.naziv AS naziv_kupca,
        k.kredit AS kreditne_mogucnosti,
        SUM(n.iznos) AS ukupni_iznos_narudzbi,

        IF(k.kredit >= SUM(n.iznos),
            'KUPAC SOLVENTAN',
            'POTREBNO ZADUŽIVANJE'
        ) AS status_kupca

    FROM kupac k
    JOIN narudzba n 
        ON k.kupacId = n.kupacId

    WHERE k.drzava = k_drzava

    GROUP BY k.kupacId, k.naziv, k.kredit;

END$$

DELIMITER ;
