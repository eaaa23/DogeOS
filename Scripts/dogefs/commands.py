from symbol import *
from tools import *


def command_createEmpty(size: int, output_filename: str, ipl_filename:str, sipl_filename:str, sipl_size_reserve:bool = False):
    checkfile_or_quit(output_filename, 'wb')

    def _check_file_and_size(filename: str, size_func: Callable[[int], bool], quit_msg: str) -> int:
        checkfile_or_quit(filename, 'rb')
        sz = int(os.path.getsize(filename))
        if not size_func(sz):
            quit_with_msg(quit_msg)
        return sz


    _check_file_and_size(ipl_filename, (lambda x: x==SELECTOR_SIZE), "IPL is not 512 bytes")
    sipl_size = _check_file_and_size(sipl_filename, (lambda x: x <= SELECTOR_SIZE*SIPL_SEL_MAX),
                                     "SIPL is too much; required lower than 512*64 bytes")
    sipl_size = SIPL_SEL_MAX if sipl_size_reserve else math.ceil(sipl_size / SELECTOR_SIZE)

    with open(output_filename, 'wb') as o_fp:
        with open(ipl_filename, 'rb') as ipl:
            o_fp.write(ipl.read())
        for i in range(8):
            o_fp.write(b'\x5a')
        o_fp.write(bytes([sipl_size, 0]))
        o_fp.write(bytes([0x02, 0x00]))

        file_fill_to(o_fp, SELECTOR_SIZE*2)

        with open(sipl_filename, 'rb') as sipl:
            o_fp.write(sipl.read())
        file_fill_to(o_fp, size)


