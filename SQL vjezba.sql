

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
    DECLARE stara DECIMAL(10,2);
    DECLARE nova DECIMAL(10,2);
    DECLARE opis VARCHAR(50);

    SELECT placa INTO stara
    FROM zaposlenik
    WHERE zaposlenikId = z_id;

    IF stara < 5000 THEN
        SET nova = stara * 1.10;
        SET opis = 'Povecanje 10%';
    ELSEIF stara <= 7000 THEN
        SET nova = stara * 1.05;
        SET opis = 'Povecanje 5%';
    ELSE
        SET nova = stara * 1.02;
        SET opis = 'Povecanje 2%';
    END IF;

    UPDATE zaposlenik
    SET placa = nova
    WHERE zaposlenikId = z_id;

    SELECT stara AS stara_placa, nova AS nova_placa, opis;
END$$
DELIMITER ;


-- 5. 
DELIMITER $$
CREATE PROCEDURE kupci_drzava(IN k_drzava VARCHAR(50))
BEGIN
    SELECT 
        k.naziv,
        k.kredit,
        SUM(n.iznos) AS ukupno,
        CASE
            WHEN k.kredit >= SUM(n.iznos) THEN 'KUPAC SOLVENTAN'
            ELSE 'POTREBNO ZADUZIVANJE'
        END AS status
    FROM kupac k
    JOIN narudzba n ON k.kupacId = n.kupacId
    WHERE k.drzava = k_drzava
    GROUP BY k.kupacId;
END$$

DELIMITER ;