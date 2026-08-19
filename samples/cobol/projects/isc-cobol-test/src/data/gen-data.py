#!/usr/bin/env python3
"""Generador datos prueba sistema bancario. COMP-3 packed decimal. 2007."""
import struct, os, random
from datetime import datetime, timedelta

random.seed(42)
OUTDIR = os.path.dirname(os.path.abspath(__file__))

def pack_comp3(value, total_digits):
    sign = 0x0C
    if value < 0: sign = 0x0D; value = -value
    digits = str(int(value)).rjust(total_digits, '0')
    result = []
    for i in range(0, len(digits), 2):
        if i + 1 < len(digits):
            b = (int(digits[i]) << 4) | int(digits[i+1])
            result.append(b)
        else:
            b = (int(digits[i]) << 4) | sign
            result.append(b)
    if len(digits) % 2 == 0 and result:
        result[-1] = (result[-1] & 0xF0) | sign
    return bytes(result)

def pack_signed_comp3(value, total_digits):
    return pack_comp3(value if value >= 0 else -value, total_digits)

def pad_string(s, length): return str(s)[:length].ljust(length, ' ')
def pad_number(n, length): return str(int(n)).rjust(length, '0')[-length:]

def build_rec(*parts):
    out = b''
    for p in parts:
        out += p.encode('ascii') if isinstance(p, str) else p
    return out

NOMBRES = ['JUAN','MARIA','CARLOS','ANA','JOSE','GUADALUPE','FRANCISCO','MARGARITA','ANTONIO',
  'LETICIA','MANUEL','TERESA','JAVIER','ROSA','MIGUEL','PATRICIA','ALEJANDRO','SANDRA','RICARDO',
  'VERONICA','FERNANDO','CLAUDIA','JORGE','LAURA','LUIS','ELIZABETH','RAFAEL','NORMA','EDUARDO','IRMA']
APELLIDOS = ['HERNANDEZ','GARCIA','MARTINEZ','LOPEZ','GONZALEZ','RODRIGUEZ','PEREZ','SANCHEZ',
  'RAMIREZ','CRUZ','FLORES','MORALES','VARGAS','CASTILLO','REYES','GUTIERREZ','ORTEGA','MENDOZA']
CIUDADES = [('CDMX','CIUDAD DE MEXICO','DISTRITO FEDERAL','01000'),('MTY','MONTERREY','NUEVO LEON','64000'),
  ('GDL','GUADALAJARA','JALISCO','44100'),('PUE','PUEBLA','PUEBLA','72000'),('TOL','TOLUCA','ESTADO DE MEXICO','50000'),
  ('LEO','LEON','GUANAJUATO','37000'),('QRO','QUERETARO','QUERETARO','76000')]
CALLES = ['AVENIDA PRINCIPAL','CALLE MORELOS','BOULEVARD REFORMA','CALLE HIDALGO','AV JUAREZ',
  'PASEO DE LA REFORMA','CALLE MADERO','AV CONSTITUCION','AV INSURGENTES','CALLE UNIVERSIDAD']
COLONIAS = ['CENTRO','DEL VALLE','CONDESA','POLANCO','SANTA FE','NAPOLES','ROMA','ANZURES','LINDAVISTA','OBRERA']

def rnd_date(s=1995, e=2026): return random.randint(s, e)*10000 + random.randint(1,12)*100 + random.randint(1,28)
def gen_phone(): return f"55{random.randint(10000000,99999999)}"

def gen_customers():
    records = []
    for i in range(1, 151):
        cid = f"CLI{i:07d}"
        paterno = random.choice(APELLIDOS); materno = random.choice(APELLIDOS)
        nombre = f"{random.choice(NOMBRES)} {paterno} {materno}"
        ciudad = random.choice(CIUDADES)
        ingreso = random.randint(5000, 250000) * 100
        records.append(build_rec(
            pad_string(cid,10), pad_string(random.choice(['PF','PF','PF','PM','GO']),2),
            pad_string(nombre,60), pad_string(paterno,30), pad_string(materno,30),
            pad_string(nombre[:40],40), pad_string('RFC'+str(random.randint(1000000000,9999999999)),13),
            pad_string('CURP'+str(random.randint(10000000000000,99999999999999)),18),
            pad_string('',20), pad_string(random.choice(CALLES),40),
            pad_string(str(random.randint(100,9999)),10), pad_string('',10),
            pad_string(random.choice(COLONIAS),30), pad_string(ciudad[1],30),
            pad_string(ciudad[2],20), pad_string('MEXICO',20), pad_string(ciudad[3],5),
            pad_string(gen_phone(),15), pad_string('',15), pad_string(gen_phone(),15),
            pad_string(f"cli{i}@email.com",50), pad_string('',40), pad_string('',30),
            pack_comp3(ingreso,11), pad_string(f"{random.randint(1,5):02d}",2),
            pad_string(random.choice(['A','A','B','C']),1),
            pad_string(random.choice(['A','A','A','A','I']),1),
            pad_number(rnd_date(2000,2020),8), pad_number(rnd_date(2020,2025),8),
            pad_number(rnd_date(2024,2026),8), pad_string('SISTEMA',8),
            pad_string('SISTEMA',8), pad_number(rnd_date(1950,1990),8),
            pad_string(random.choice(['M','F']),1), pad_string('MEX',3),
            pad_string(str(random.randint(100000,999999)),6), pad_string('',20)))
    return records

def gen_accounts():
    records = []
    for i in range(1, 151):
        a = f"CTA{i:07d}"; t = random.choice(['CH','AH','AH','NO','IN'])
        bal = random.randint(-50000, 5000000)*100
        records.append(build_rec(
            pad_string(a,10), pad_string(t,2),
            pad_string(random.choice(['MXN','MXN','MXN','USD']),3),
            pack_signed_comp3(bal,15), pack_signed_comp3(max(0,bal-random.randint(0,100000)),15),
            pack_signed_comp3(random.randint(0,50000)*100,15), pack_signed_comp3(abs(min(0,bal)),15),
            pack_signed_comp3(random.randint(0,1000000)*100,15), pack_signed_comp3(random.randint(0,2000000)*100,15),
            pack_signed_comp3(random.randint(0,50000)*100,11), pack_comp3(random.randint(1500,6000),7),
            pack_comp3(random.randint(100,1500),7), pack_signed_comp3(random.randint(0,10000)*100,11),
            pack_comp3(random.choice([0,0,25,50,100,150])*100,9),
            pad_number(rnd_date(2000,2025),8), pad_number(0,8), pad_number(rnd_date(2025,2026),8),
            pad_number(rnd_date(2025,2026),8), pad_number(rnd_date(2025,2026),8),
            pad_string(random.choice(['A','A','A','I']),1), pad_string(f"{random.randint(1,10):04d}",4),
            pad_string(f"OF{random.randint(1,99):06d}",8), pad_string(f"USR{random.randint(1,20):05d}",8),
            pad_number(random.randint(0,99),6), pad_number(random.randint(0,500),6),
            pad_number(random.randint(0,50) if t=='CH' else 0,6), pad_number(0,6),
            pad_string(f"CHQ{i:07d}" if t=='CH' else '',10),
            pad_number(random.randint(1000,9999) if t=='CH' else 0,7),
            pad_number(random.randint(1,1000) if t=='CH' else 0,7), pad_number(random.randint(0,5),3),
            pad_string('',15)))
    return records

def gen_tranlog():
    records = []
    txs = ['DEP','DEP','DEP','RET','RET','TRF','PAG','CHQ','INT','COM']
    for i in range(1, 501):
        d = 20260101 + random.randint(0,180); h = random.randint(6,22)
        amt = random.randint(100,5000000)*100
        if random.random()<0.3: amt = -abs(amt)
        records.append(build_rec(
            pad_number(i,10), pad_number(d,8),
            pad_number(h*10000+random.randint(0,59)*100+random.randint(0,59),6),
            pad_string(random.choice(txs),3), pad_string(f"CTA{random.randint(1,150):07d}",10),
            pad_string('',10), pad_string(f"CLI{random.randint(1,150):07d}",10),
            pack_signed_comp3(amt,15), pack_signed_comp3(0,11), pack_signed_comp3(amt,15),
            pack_signed_comp3(amt,15), pack_signed_comp3(random.choice([0,0,1500,2500]),9),
            pad_string('F001' if random.random()<0.2 else '',4),
            pad_string(f"{random.randint(1,10):04d}",4), pad_string(f"TLR{random.randint(1,30):06d}",8),
            pad_string(f"USR{random.randint(1,20):05d}",8), pad_string(f"TERM{random.randint(1,50):04d}",8),
            pad_string('01',2), pad_string(f"REF{i:010d}",20),
            pad_number(0,10), pad_string('',10), pad_string('',10),
            pad_string(random.choice(['C','C','C','P','V']),1), pad_number(0,10),
            pad_string(random.choice(['DEPOSITO','RETIRO','TRANSFERENCIA','PAGO']),30),
            pad_string('',10)))
    return records

def gen_loanmast():
    records = []
    for i in range(1, 51):
        approved = random.randint(50000, 50000000)*100
        parts = [
            pad_string(f"LON{i:07d}",10), pad_string(f"APL{i:07d}",10),
            pad_string(f"CLI{random.randint(1,150):07d}",10),
            pad_string(random.choice(['PL','HI','AU','CO','PR','RE']),2),
            pad_string(random.choice(['PERP','HIP1','AUTO','COME']),4),
            pack_comp3(approved,15), pack_comp3(int(approved*0.9),15),
            pack_comp3(int(approved*0.6),15), pack_comp3(int(approved*0.1) if random.random()<0.3 else 0,15),
            pack_comp3(int(approved*0.05),15), pack_comp3(int(approved*0.02),11),
            pack_comp3(int(approved/12),11), pack_comp3(random.randint(800,4500),7),
            pack_comp3(random.randint(1000,5000),7), pack_comp3(random.randint(1500,6000),7),
            pack_comp3(int(approved*0.01),9), pad_number(60,4), pad_number(0,4),
            pad_string('M',1), pad_number(60,4), pad_number(random.randint(0,60),4),
            pad_number(0,4), pad_string('F',1), pack_comp3(int(approved/60),11),
            pad_number(15,2), pad_number(rnd_date(2022,2025),8), pad_number(rnd_date(2022,2025)+10000,8),
            pad_number(rnd_date(2022,2026),8), pad_number(rnd_date(2025,2026),8),
            pad_number(rnd_date(2022,2025)+600000,8), pad_number(rnd_date(2025,2026),8),
            pad_string('',2), pad_string('CASA HABITACION',40),
            pack_comp3(int(approved*0.8),15), pad_string(f"CTA{random.randint(1,150):07d}",10),
            pad_string(f"CTA{random.randint(1,150):07d}",10)]
        for j in range(1, 361):
            parts += [pad_number(j,4), pad_number(0,8), pack_comp3(0,11),
                      pack_comp3(0,11), pack_comp3(0,11), pack_comp3(0,11), pad_string('P',1)]
        parts += [pad_string('A',1), pad_string('1',1), pad_string(f"OF{random.randint(1,99):06d}",8),
                  pad_string('SISTEMA',8), pad_number(rnd_date(2025,2026),8), pad_string('',30)]
        records.append(build_rec(*parts))
    return records

def gen_cards():
    records = []
    for i in range(1, 81):
        records.append(build_rec(
            pad_string(f"4000{i:012d}",16), pad_string(f"{random.choice(NOMBRES)} {random.choice(APELLIDOS)}",30),
            pad_string(random.choice(['DB','DB','CR','CR','PP']),2),
            pad_string(random.choice(['CLAS','CLAS','GOLD','PLAT','BLCK']),4),
            pad_string(f"CLI{random.randint(1,150):07d}",10),
            pad_string(f"CTA{random.randint(1,150):07d}",10),
            pad_string(f"{random.randint(1,10):04d}",4),
            pad_number(rnd_date(2020,2025),8), pad_number(rnd_date(2020,2025)+30000,8),
            pad_number(rnd_date(2025,2026) if random.random()<0.7 else 0,8),
            pad_number(rnd_date(2020,2025)+random.randint(1000,10000),8),
            pack_comp3(random.choice([3000,5000,10000,15000,20000])*100,11),
            pack_comp3(random.choice([10000,20000,50000,100000])*100,11),
            pack_comp3(random.randint(2000,10000)*100,11),
            pack_comp3(random.randint(5000,50000)*100,11),
            pack_comp3(5000000,11),
            pack_signed_comp3(random.randint(-50000,200000)*100,11),
            pack_signed_comp3(random.randint(1000,500000)*100,11),
            pack_signed_comp3(random.randint(0,50000)*100 if random.random()<0.2 else 0,11),
            pack_signed_comp3(0,11), pack_comp3(random.randint(2000,6000),7),
            pad_number(random.randint(1,28),2), pad_number(15,2),
            pad_string(str(random.randint(1000,9999)),6), pad_string(str(random.randint(100,999)),4),
            pad_number(random.randint(0,3),2), pad_string('N',1),
            pad_string(random.choice(['A','A','A','A','A','B','L']),1),
            pad_string('',40), pad_number(random.randint(1,3),2), pad_number(random.randint(0,50),3),
            pack_comp3(random.randint(0,50000)*100,11),
            pad_string(random.choice(['Y','Y','N']),1), pad_string('',15)))
    return records

def gen_userprof():
    data = [
        ('ADMIN01','ADMINISTRADOR SISTEMA','ADM','0001','SIST'),
        ('GERENT01','GERENTE GENERAL','GER','0001','OPER'),
        ('SUPVSR01','SUPERVISOR OPERACIONES','SUP','0001','OPER'),
        ('CAJERO01','CAJERO PRINCIPAL','CAJ','0001','OPER'),
        ('CAJERO02','CAJERO AUXILIAR','CAJ','0001','OPER'),
        ('OFICIA01','OFICIAL DE CREDITO','OFI','0001','CRED'),
        ('AUDITR01','AUDITOR INTERNO','AUD','0001','AUDI'),
        ('CONSUL01','CONSULTA SALDOS','CON','0001','SIST'),
        ('GERENT02','GERENTE SUC 2','GER','0002','OPER'),
        ('CAJERO03','CAJERO SUC 2','CAJ','0002','OPER'),
        ('SUPVSR02','SUPERVISOR SUC 2','SUP','0002','OPER'),
        ('GERENT03','GERENTE SUC 3','GER','0003','OPER'),
        ('CAJERO04','CAJERO SUC 3','CAJ','0003','OPER'),
        ('ADMIN02','ADMIN BACKUP','ADM','0001','SIST'),
        ('SISTEMA','USUARIO BATCH','ADM','0001','SIST'),
        ('CONSUL02','CONSULTA EXTERNA','CON','0001','SIST'),
        ('OFICIA02','OFICIAL SERVICIOS','OFI','0002','OPER'),
        ('AUDITR02','AUDITOR EXTERNO','AUD','0001','AUDI'),
        ('SUPVSR03','SUPERVISOR SUC 3','SUP','0003','OPER'),
        ('GERENT04','GERENTE SUC 4','GER','0004','OPER'),
    ]
    records = []
    for uid, name, role, branch, dept in data:
        records.append(build_rec(
            pad_string(uid,8), pad_string(name,40), pad_string('APELLIDO',30),
            pad_string('NOMBRE',30), pad_string(f"PWD{uid[-4:]}",20),
            pad_number(rnd_date(2026,2028),8), pad_number(rnd_date(2025,2026),8),
            pad_number(0,2), pad_string('N',1), pad_string('N',1),
            pad_string(role,3), pad_string(branch,4), pad_string(dept,4),
            pad_number(700,4), pad_number(2200,4), pad_string('192.168.*.*',15),
            pad_number(3,2), pad_number(600,4),
            pad_string(f"{uid.lower()}@banco.com",50), pad_string(gen_phone(),15),
            pad_string(str(random.randint(1000,9999)),5), pad_string('A',1),
            pad_number(rnd_date(2000,2023),8), pad_number(0,8),
            pad_number(rnd_date(2025,2026),8), pad_number(random.randint(80000,180000),6),
            pad_string('',20)))
    return records

def gen_branches():
    data = [
        ('0001','SUCURSAL CENTRAL CDMX','0001','CDMX','O',19950101),
        ('0002','SUCURSAL MONTERREY','0002','MTY','O',19980101),
        ('0003','SUCURSAL GUADALAJARA','0002','GDL','O',20000101),
        ('0004','SUCURSAL PUEBLA','0002','PUE','O',20020101),
        ('0005','SUCURSAL TOLUCA','0001','TOL','O',20030101),
        ('0006','SUCURSAL LEON','0002','LEO','O',20040101),
        ('0007','SUCURSAL QUERETARO','0002','QRO','O',20050101),
        ('0008','SUCURSAL MERIDA','0003','MER','O',20060101),
        ('0009','SUCURSAL TIJUANA','0003','TJU','O',20070101),
        ('0010','SUCURSAL CANCUN','0003','CUN','O',20080101),
    ]
    records = []
    for code, name, region, city, status, dateo in data:
        records.append(build_rec(
            pad_string(code,4), pad_string(name,40), pad_string(name[:15],15),
            pad_string('AV PRINCIPAL',40), pad_string('100',10), pad_string('CENTRO',30),
            pad_string(city,30), pad_string('ESTADO',20), pad_string('00000',5),
            pad_string(gen_phone(),15), pad_string('GERENT01',8),
            pad_number(900,4), pad_number(1800,4), pad_number(900,4), pad_number(1400,4),
            pad_number(0,4), pad_number(0,4),
            pack_comp3(random.randint(1000000,50000000)*100,13),
            pack_comp3(random.randint(5000000,100000000)*100,13),
            pad_string(f"GL{code}0001",8), pad_string(region,2), pad_string(status,1),
            pad_number(dateo,8), pad_number(random.randint(5,50),4),
            pad_number(random.randint(1,5),2), pad_number(random.randint(10,200),6),
            pad_string('',30)))
    return records

def gen_acctxref():
    records = []
    used = set()
    for i in range(1, 201):
        while True:
            c = f"CLI{random.randint(1,150):07d}"
            a = f"CTA{random.randint(1,150):07d}"
            if c+a not in used: used.add(c+a); break
        records.append(build_rec(
            pad_string(c+a,20), pad_string(c,10), pad_string(a,10),
            pad_string(random.choice(['TI','TI','CO','BE','AU']),2),
            pack_comp3(random.randint(1000,10000),5),
            pad_number(rnd_date(2000,2025),8), pad_number(0,8),
            pad_string('A',1), pad_string('SISTEMA',8), pad_string('',17)))
    return records

def gen_paramstr():
    params = [
        ('FECHA_NEG','GENERAL','FECHA NEGOCIO','',0,20260701,'F','S'),
        ('TASA_BASE','TASAS','TASA REFERENCIA','',115000,0,'N','S'),
        ('TASA_CHEQUES','TASAS','TASA CHEQUES','',500,0,'N','S'),
        ('TASA_AHORRO','TASAS','TASA AHORRO','',3500,0,'N','S'),
        ('LIM_EFECTIVO','LIMITES','LIMITE EFECTIVO','',5000000,0,'N','S'),
        ('LIM_TRANSFER','LIMITES','LIMITE TRANSFERENCIA','',99999900,0,'N','S'),
        ('HORA_APERTURA','HORARIO','HORA APERTURA','',900,0,'N','S'),
        ('HORA_CIERRE','HORARIO','HORA CIERRE','',1800,0,'N','S'),
        ('HORA_CORTE','HORARIO','HORA CORTE','',1800,0,'N','S'),
        ('COM_MENSUAL','COMISION','COMISION MENSUAL','',5000,0,'N','S'),
        ('COM_REPOS','COMISION','COMISION REPOSICION','',35000,0,'N','S'),
        ('INT_MAX_LOGIN','SEGURIDAD','INTENTOS MAX LOGIN','',3,0,'N','S'),
        ('SESSION_TIMEOUT','SEGURIDAD','TIMEOUT SESION','',600,0,'N','S'),
        ('DURACION_PWD','SEGURIDAD','DURACION PASSWORD','',90,0,'N','S'),
        ('MONEDA_BASE','GENERAL','MONEDA BASE','MXN',0,0,'T','N'),
        ('PAIS','GENERAL','PAIS','MEXICO',0,0,'T','N'),
        ('IDIOMA','GENERAL','IDIOMA','ES',0,0,'T','S'),
        ('INT_METODO','GENERAL','METODO INTERES','FRANCESA',0,0,'T','S'),
        ('GL_CAJA','CONTABLE','GL CAJA','10000001',0,0,'T','N'),
        ('GL_BANCO','CONTABLE','GL BANCO','10000002',0,0,'T','N'),
        ('GL_INTERES','CONTABLE','GL INTERES','50000001',0,0,'T','N'),
        ('GL_COMISION','CONTABLE','GL COMISION','50000002',0,0,'T','N'),
        ('IVA_TASA','GENERAL','TASA IVA','',160000,0,'N','N'),
        ('TASA_MORA','TASAS','TASA MORA','',12000,0,'N','S'),
        ('TASA_NOMINA','TASAS','TASA NOMINA','',200,0,'N','S'),
        ('FEE_DIA','COMISION','DIA COBRO COMISION','',15,0,'N','S'),
        ('HORA_SABADO','HORARIO','SABADO APERTURA','',900,0,'N','S'),
        ('HORA_SAB_C','HORARIO','SABADO CIERRE','',1400,0,'N','S'),
        ('CORTE_MENSUAL','GENERAL','CORTE MENSUAL','',25,0,'N','S'),
        ('PAIS_DEF','GENERAL','PAIS DEFAULT','MEX',0,0,'T','N'),
    ]
    records = []
    for cod, grupo, desc, txt, num, fec, tipo, modif in params:
        records.append(build_rec(
            pad_string(cod,8), pad_string(grupo,10), pad_string(desc,40),
            pad_string(txt,40), pack_signed_comp3(num,15),
            pad_number(fec,8), pad_string(tipo,1), pad_string(modif,1),
            pad_number(rnd_date(2025,2026),8), pad_string('SISTEMA',8),
            pad_string('',5)))
    return records

def gen_auditlog():
    records = []
    eventos = ['AL','BA','CA','CO','IM','RE','AU','CI','BL']
    ents = ['CL','CT','PR','TJ','US','PA','TA','SU','TR']
    progs = ['CRDINQ00','CRDBLK00','CRDREP00','CRDPIN00','CRDMOV00',
             'CRDLMT00','CRDALR00','SECUSR00','ADMROL00','ADMBRH00',
             'ADMPAR00','ADMAUD00','ADMLOG00','ADMCFG00','BNK0001']
    for i in range(1, 101):
        d = rnd_date(2025,2026); h = random.randint(6,23)
        records.append(build_rec(
            pad_number(i,10), pad_number(d,8), pad_number(h*10000+random.randint(0,59)*100+random.randint(0,59),6),
            pad_string(random.choice(['ADMIN01','GERENT01','CAJERO01','AUDITR01']),8),
            pad_string(f"TERM{random.randint(1,50):04d}",8),
            pad_string(random.choice(progs),8), pad_string(random.choice(eventos),2),
            pad_string(random.choice(ents),2),
            pad_string(random.choice([f"CLI{random.randint(1,150):07d}",f"CTA{random.randint(1,150):07d}",
              f"4000{random.randint(1,80):012d}",f"USR{random.randint(1,20):05d}"]),20),
            pad_string('VALOR ANTERIOR',60), pad_string('VALOR NUEVO',60),
            pad_string(random.choice(['O','R','E']),1),
            pad_string(random.choice(['OPERACION NORMAL','AUTORIZADO','BLOQUEO PREVENTIVO','RECHAZADO']),30),
            pad_string('',15)))
    return records

def write_records(filename, records):
    path = os.path.join(OUTDIR, filename)
    with open(path, 'wb') as f:
        for rec in records:
            f.write(rec.encode('ascii') if isinstance(rec, str) else rec)
    print(f"  {filename}: {len(records)} reg {os.path.getsize(path)} bytes")

def main():
    print("GENERANDO DATOS...")
    write_records('CUSTOMER.DAT', gen_customers())
    write_records('ACCOUNT.DAT', gen_accounts())
    write_records('TRANLOG.DAT', gen_tranlog())
    write_records('LOANMAST.DAT', gen_loanmast())
    write_records('CARD.DAT', gen_cards())
    write_records('USERPROF.DAT', gen_userprof())
    write_records('BRANCH.DAT', gen_branches())
    write_records('ACCTXREF.DAT', gen_acctxref())
    write_records('PARAMSTR.DAT', gen_paramstr())
    write_records('AUDITLOG.DAT', gen_auditlog())
    print("COMPLETO.")

if __name__ == '__main__':
    main()
