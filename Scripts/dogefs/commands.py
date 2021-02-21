from symbols import *
from tools import *


def command_createEmpty(size: int, output_filename: str, ipl_filename:str, sipl_filename:str,
                        os_filename:str, sipl_size_reserve:bool = False):
    checkfile_or_quit(output_filename, 'wb')

    def _check_file_and_size(filename: str, size_func: Callable[[int], bool], quit_msg: str) -> int:
        checkfile_or_quit(filename, 'rb')
        sz = int(os.path.getsize(filename))
        if not size_func(sz):
            quit_with_msg(quit_msg)
        return sz


    _check_file_and_size(ipl_filename, (lambda x: x==SELECTOR_SIZE), "IPL is not 512 bytes")
    sipl_size = _check_file_and_size(sipl_filename, (lambda x: x <= SELECTOR_SIZE*SIPL_SEL_MAX),
                                     "SIPL is too much; required lower than {:d}*{:d} bytes".format(SELECTOR_SIZE, SIPL_SEL_MAX))
    sipl_size = SIPL_SEL_MAX if sipl_size_reserve else math.ceil(sipl_size / SELECTOR_SIZE)

    os_size = _check_file_and_size(os_filename, (lambda x: x <= SELECTOR_SIZE*OS_SEL_MAX),
                                   "OS Size is too much; required lower than {:d}*{:d} bytes".format(SELECTOR_SIZE, OS_SEL_MAX))
    os_size = math.ceil(os_size / SELECTOR_SIZE)
    os_loc = sipl_size + 2
    fs_size = math.ceil(size / SELECTOR_SIZE)
    if os_loc + os_size > fs_size:
        quit_with_msg("File system size too small.")

    with open(output_filename, 'wb') as o_fp:
        with open(ipl_filename, 'rb') as ipl:
            o_fp.write(ipl.read())
        for i in range(8):
            o_fp.write(b'\x5a')                 # ID
        o_fp.write(bytes([sipl_size, 0]))       # sipl size
        o_fp.write(bytes([0x02, 0x00]))         # sipl loc
        o_fp.write(int2bytes(fs_size, 6))       # FS Size
        o_fp.write(int2bytes(os_size, 2))       # OS Size
        o_fp.write(int2bytes(os_loc,  4))

        file_fill_to(o_fp, SELECTOR_SIZE*2)

        with open(sipl_filename, 'rb') as sipl:
            o_fp.write(sipl.read())
        file_fill_to(o_fp, size)


