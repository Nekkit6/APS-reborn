/* -----------------------------------------------------------------------------
* Project Name   : Architectures of Processor Systems (APS) lab work
* Organization   : National Research University of Electronic Technology (MIET)
* Department     : Institute of Microdevices and Control Systems
* Author(s)      : Andrei Solodovnikov
* Email(s)       : hepoh@org.miet.ru

See https://github.com/MPSU/APS/blob/master/LICENSE file for licensing details.
* ------------------------------------------------------------------------------
*/
_start:
# Инициализируем начальные значения регистров
 0: 030000b7        li x1, 0x03000000           # сохраняем базовый адрес клавиатуры
 4: 07000137        li x2, 0x07000000           # сохраняем базовый адрес vga-контроллера
 8: 070011b7        li x3, 0x07000960           # количество символов на экране
 c:                                             # данная псевдоинструкция будет разбита на две
                                                # инструкции: lui и addi
10: 96018193        li x5, 0x00000001           # подготавливаем маску прерывания единственного
                                                # (нулевого) входа
14: 00100293        csrw mie, x5                # загружаем маску в регистр маски
18: 30429073        la x5, trap_handler         # псевдоинструкция la аналогично li загружает число,
                                                # только в случае la — это число является адресом
                                                # указанного места (адреса обработчика перехвата)
                                                # данная псевдоинструкция будет разбита на две
                                                # инструкции: lui и addi
1c: 30529073        csrw mtvec, x5              # устанавливаем вектор прерывания

# Вызов функции main
main:
20:	00000063        beq x0, x0, main            # бесконечный цикл, аналогичный while (1);

# ОБРАБОТЧИК ПЕРЕХВАТА
# Без стороннего вмешательства процессор никогда не перейдет к инструкциям ниже,
# однако в случае прерывания в программный счетчик будет загружен адрес первой
# нижележащей инструкции.
# Сохраняем используемые регистры на стек
trap_handler:
24: 0000a383        lw x7, 0(x1)                # загружаем сканкод
28: 00038403        lb x8, 0(x7)                # берем данные из таблицы подстановки
2c: 00810023        sb x8, 0(x2)                # загружаем ascii-значение в vga
30: 00110113        addi x2, x2, 1              # инкрементируем адрес vga
34: 00315463        bge x2, x3, wrap_addr       # если адрес vga вышел за границы, то обнуляем
38: 30200073        mret                        # возвращаем управление программе (pc = mepc)
                            # что означает возврат в бесконечный цикл
wrap_addr:
3c: 07000137        li x2, 0x07000000           # сохраняем базовый адрес vga-контроллера
40: 30200073        mret
