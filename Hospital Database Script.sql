CREATE DATABASE hospital;
USE hospital;

CREATE TABLE PATIENT (
	patient_id int PRIMARY KEY AUTO_INCREMENT,
	fname varchar(45),
    lname varchar(45) NOT NULL,
    gender char,
    phone_no varchar(11),
    address varchar(11),
    age int
    );

CREATE TABLE STAFF (
	employee_id int PRIMARY KEY,
	fname varchar(45),
    lname varchar(45) NOT NULL,
    phone_no varchar(11),
    salary double(10,2)  
    );
    
CREATE TABLE DEPARTMENT (
	department_id varchar(45) PRIMARY KEY,
    head_doctor varchar(45),
    
    CONSTRAINT department_fk FOREIGN KEY(doctor_id) REFERENCES DOCTOR(doctor_id)
    );    

CREATE TABLE DOCTOR (
	doctor_id varchar(45) PRIMARY KEY,
    employee_id int,
    department_id varchar(45),
    
    CONSTRAINT doctor_fk1 FOREIGN KEY(employee_id) REFERENCES STAFF(employee_id),
    CONSTRAINT doctor_fk2 FOREIGN KEY(department_id) REFERENCES DEPARTMENT(department_id)
    );    

-- room numbers start incrementing from 100
ALTER TABLE ROOM AUTO_INCREMENT = 100;

CREATE TABLE ROOM (
	room_no int NOT NULL AUTO_INCREMENT,
    department_id varchar(45),
    floor int,    
    room_type varchar(45),
    avaliable char,
    
    PRIMARY KEY (room_no),
    CONSTRAINT room_fk FOREIGN KEY(department_id) REFERENCES DEPARTMENT(department_id)
    );
    
CREATE TABLE APPOINTMENT (
	appointment_id int NOT NULL AUTO_INCREMENT,
    doctor_id varchar(45),
    patient_id int,
    room int,
    date_and_time datetime,
    
    PRIMARY KEY (appointment_id),
    CONSTRAINT appintment_fk1 FOREIGN KEY(patient_id) REFERENCES PATIENT(patient_id),
    CONSTRAINT appintment_fk2 FOREIGN KEY(room) REFERENCES ROOM(room_no),
    CONSTRAINT appintment_fk3 FOREIGN KEY(doctor_id) REFERENCES DOCTOR(doctor_id)
    );

ALTER TABLE APPOINTMENT AUTO_INCREMENT=50;

CREATE TABLE MEDICATION (
	medication_id varchar(45) PRIMARY KEY,
    med_description varchar(45),
    cost_per_month float(7,2)
    );
    
CREATE TABLE PRESCRIPTION (
	prescription_id int NOT NULL AUTO_INCREMENT,
    issued_by varchar(45),
    patient_id int,
	medication_id varchar(45),
    months_taking float(7,2),
    
    PRIMARY KEY(prescription_id),
    CONSTRAINT prescription_fk1 FOREIGN KEY(doctor_id) REFERENCES DOCTOR(doctor_id),
	CONSTRAINT prescription_fk2 FOREIGN KEY(patient_id) REFERENCES PATIENT(patient_id),
    CONSTRAINT prescription_fk3 FOREIGN KEY(medication_id) REFERENCES MEDICATION(medication_id)
    );



-- 					TASKS --
-- 			 tables
SELECT * FROM PATIENT;
SELECT * FROM DOCTOR;
SELECT * FROM STAFF;
SELECT * FROM DEPARTMENT ORDER BY department_id;
SELECT * FROM PRESCRIPTION;
SELECT * FROM MEDICATION;
SELECT * FROM ROOM;
SELECT * FROM APPOINTMENT;

--         QUERY
-- number of avaliable rooms in total & on each floor
SELECT floor, COUNT(r.avaliable) FROM room r WHERE avaliable = "t" GROUP BY r.floor;

-- Show staff who are not doctors (from the employee table, find those who are not in the doctor table using employee_id)
SELECT * FROM STAFF WHERE employee_id NOT IN (SELECT employee_id FROM DOCTOR);

SELECT employee_id, salary FROM STAFF WHERE employee_id NOT IN (SELECT employee_id FROM DOCTOR) AND salary < 50000;


-- 			Use JOIN & GROUP BY
-- 	find total cost of patients' prescription and join into new table. "Receipt"
SELECT p.prescription_id, p.patient_id, p.medication_id, (p.months_taking * MEDICATION.cost_per_month) AS total_cost
FROM PRESCRIPTION p JOIN MEDICATION on MEDICATION.medication_id = p.medication_id
GROUP BY p.prescription_id ORDER BY p.prescription_id;


--         Create a VIEW w/ 3-4 tables
-- 	find total cost of patients' prescription and join into view. "Receipt" (includes names)
CREATE VIEW patientReceipt AS
SELECT p.prescription_id, PATIENT.patient_id, PATIENT.first_name, PATIENT.last_name, (p.months_taking * MEDICATION.cost_per_month) AS total_cost
FROM PRESCRIPTION p
INNER JOIN MEDICATION ON MEDICATION.medication_id = p.medication_id
INNER JOIN PATIENT ON PATIENT.patient_id = p.patient_id;

SELECT * FROM patientReceipt ORDER BY prescription_id;


--          Create a STORED FUNCTION that can be applied to a query
-- find out whether a patient qualifies for free medication based on their age.
DELIMITER //
CREATE FUNCTION freeHealthcare(
	age int
)
RETURNS varchar(3)
DETERMINISTIC
BEGIN
	DECLARE FreeHealthcare varchar(3);
    
    IF age <= 18 OR age >= 60 THEN
		SET FreeHealthcare = 'yes';
	ELSE
		SET FreeHealthcare = 'no';
	END IF;
		RETURN (FreeHealthcare);
END//
DELIMITER ;

select patient_id, FreeHealthcare(age) FROM PATIENT;

-- EBI? if FreeHealthcare function is true then in the prescriptionReceipt, the total cost should be 0.

INSERT INTO PATIENT (patient_id, fname, lname, gender, phone_no, address, age) VALUES 
	('1','Sol', 'Hodson', 'M', '07700900752', 'West Park Walk rd', '41'),
	('2','Amaan', 'Ramsey', 'M', '01214960749', 'Hillfield Warren rd', '21'),
	('3','Kristie ', 'Maynard', 'F', '02079460402', 'Squires Glen st', '36'),
	('4','Jeffery  ', 'Dotson', 'M', '01614960252', 'Mountbatten Orchards st', '12'),
	('5','Vicky', 'Rees', 'F', '01184960957', 'Howards Gardens st', '76'),
	('6','Dawud', 'Laing', 'M', '07700900749', 'Frederick Nook rd', '27'),
	('7','Alysha', 'Strickland', 'F', '06705907752', 'Hollin Top st', '3'),
	('8','Shae', 'Mckay', 'F', '03214460759', 'Trinity Drift st', '17'),
	('9','Frank', 'Emerson', 'M', '02079469422', 'St Georges Ridgeway st', '87'),
	('10','Sarah-Jane', 'Mcdougall', 'F', '04654760282', 'Latham Dells rd', '45'),
	('11','Amaya', 'Hahn', 'F', '01164869922', 'Philip Town st', '73'),
	('12','Alby', 'Griffiths', 'M', '07508990344', 'Saxon Woodlands st', '43');

INSERT INTO STAFF (employee_id, fname, lname, phone_no) VALUES 
	('781635', 'Musa', 'Yates', '06624260382'),
	('817837', 'Murtaza', 'Mercado', '03174465729'),
	('529679', 'Karolina', 'Trejo', '03705400549'),
	('311011', 'Lilliana', 'Hewitt', '02039469422'),
	('893310', 'Dominique', 'Humphreys', '07338994344'),
	('654270', 'Farhana', 'Oneil', '02635764262'),
	('221765', 'Iga', 'Begum', '01284630757'),
	('330042', 'Kiana', 'Manning', '03075469472'),
	('592394', 'Kaia', 'Herrera', '04632763287'),
	('755078', 'Brent', 'Wheatley', '03481444752'),
	('366194', 'Alex', 'Fellows', '05556760242'),
	('276462', 'Kaylum', 'Whitworth', '07207900789');

INSERT INTO DEPARTMENT (department_id, head_doctor) VALUES 
	('Cardiology', 'DOC5457'),
	('Pharmacy', ''),
	('Maternity', 'DOC6100'),
	('General surgery', 'DOC7908'),
	('Critical care', 'DOC2489'),
	('A&E', 'DOC2521'),
	('Pediatric', '');

INSERT INTO DOCTOR (doctor_id, employee_id, department_id) VALUES 
	('DOC5457', '755078', 'Cardiology'),
	('DOC2489', '221765', 'Critical care'),
	('DOC6100', '893310', 'Maternity'),
	('DOC7706', '276462', 'General surgery'),
	('DOC7908', '781635', 'General surgery'),
	('DOC8897', '311011', 'Cardiology'),
	('DOC2521', '330042', 'A&E'),
	('DOC3885', '817837', 'Cardiology');

INSERT INTO ROOM (department_id, floor, room_type, avaliable) VALUES
	('Cardiology', '1', 'single', 't'),
	('Cardiology', '1', 'single', 'f'),
	('Cardiology', '1', 'twin', 't'),
	('Cardiology', '1', 'single', 'f'),
	('Cardiology', '2', 'single', 'f'),
	('Cardiology', '2', 'twin', 't'),
	('Cardiology', '2', 'single', 'f'),
	('Maternity', '1', 'single', 't'),
	('Maternity', '1', 'single', 'f'),
	('Maternity', '1', 'single', 'f'),
	('Maternity', '1', 'single', 'f'),
	('General surgery', '1', 'single', 'f'),
	('General surgery', '1', 'single', 't'),
	('General surgery', '1', 'single', 'f'),
	('General surgery', '2', 'single', 't'),
	('General surgery', '2', 'single', 'f'),
	('General surgery', '2', 'single', 't'),
	('A&E', '1', 'ward', 't'),
	('A&E', '1', 'ward', 'f'),
	('A&E', '1', 'ward', 'f'),
	('A&E', '1', 'ward', 't'),
	('A&E', '2', 'ward', 't'),
	('A&E', '2', 'ward', 'f'),
	('A&E', '2', 'ward', 'f'),
	('A&E', '2', 'ward', 'f'),
	('Pediatric', '1', 'single', 't'),
	('Pediatric', '2', 'single', 'f'),
	('Critical care', '1', 'ward', 't'),
	('Critical care', '2', 'ward', 'f');

INSERT INTO MEDICATION (medication_id, med_description, cost_per_month) VALUES 
	('PARACETAMOL', 'used to treat aches and pain', '5'),
	('IBUPROFEN', 'used to relieve pain from various conditions', '7'),
	('BISOPROLOL', 'used to treat high blood pressure (hypertension) and heart failure', '3'),
	('ASPRIN', 'used to reduce fever and relieve mild to moderate pain', '9'),
	('WARFARIN', 'used to prevent blood clots from forming or growing larger', '4'),
	('AMOXICILLIN', 'used to treat bacterial infections', '6'),
	('SALBUTAMOL', 'used to relieve symptoms of asthma and COPD', '7');

INSERT INTO APPOINTMENT (doctor_id, patient_id, room, date_and_time) VALUES
	('DOC5457', '1', '100', '2021-12-04 11:00:00'),
	('DOC5457', '10', '104', '2021-12-02 11:00:00'),
	('DOC2489', '5', '105', '2021-12-29 14:00:00'),
	('DOC5457', '5', '101', '2021-12-17 19:00:00'),
	('DOC5457', '9', '124', '2021-12-09 12:00:00'),
	('DOC2489', '4', '107', '2021-12-06 11:00:00'),
	('DOC2489', '6', '102', '2021-12-15 14:00:00'),
    ('DOC2489', '7', '117', '2021-12-04 08:00:00'),
	('DOC6100', '4', '106', '2021-12-04 11:00:00'),
	('DOC6100', '11', '104', '2021-12-02 10:00:00'),
	('DOC6100', '1', '122', '2021-12-12 11:00:00'),
	('DOC7706', '2', '121', '2021-12-19 09:00:00'),
	('DOC7706', '4', '103', '2021-12-30 12:00:00'),
	('DOC7706', '2', '109', '2021-12-06 11:00:00'),
	('DOC7908', '3', '108', '2021-12-04 15:00:00'),
    ('DOC7908', '7', '108', '2021-12-04 11:00:00'),
	('DOC8897', '12', '100', '2021-12-11 11:00:00'),
	('DOC2521', '3', '127', '2021-12-18 15:00:00'),
    ('DOC3885', '8', '120', '2021-12-21 16:00:00');
    
INSERT INTO PRESCRIPTION (doctor_id, patient_id, medication_id, months_taking) VALUES
	('DOC3885', '8', 'PARACETAMOL', '1'),
    ('DOC2521', '3', 'BISOPROLOL', '4'),
    ('DOC8897', '12', 'WARFARIN', '15'),
	('DOC7908', '7', 'SALBUTAMOL', '24'),
	('DOC7908', '3', 'ASPRIN', '6'),
	('DOC7706', '2', 'ASPRIN', '12'),
	('DOC7706', '4', 'BISOPROLOL', '9'),
    ('DOC7706', '2', 'PARACETAMOL', '2'),
    ('DOC6100', '1', 'AMOXICILLIN', '11'),
	('DOC6100', '11', 'ASPRIN', '14'),
	('DOC6100', '4', 'PARACETAMOL', '3'),
	('DOC7706', '2', 'IBUPROFEN', '7');
    