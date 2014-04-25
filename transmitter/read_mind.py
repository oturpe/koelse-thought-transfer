import sys
import threading
import nia as NIA
import time

# global scope stuff
nia = None
nia_data = None
out_data = None

def update(out):
    """ out - if output values. False is useful for warming up period.
    """
    # kick-off processing data from the NIA
    data_thread = threading.Thread(target=nia_data.get_data)
    data_thread.start()

    # get the fourier data from the NIA
    data, steps = nia_data.fourier(nia_data)

    # wait for the next batch of data to come in
    data_thread.join()

    # exit if we cannot read data from the device
    if nia_data.AccessDeniedError:
        sys.exit(1)

    if not out:
        return

    return data

if __name__ == "__main__":
    """
        The main function opens the NIA, reads recording length from command
        line arguments and records values from NIA until requested length is
        reached. The last recorded thought is the output.

        If no record length argument is given, defaults to 10.
    """

    if len(sys.argv) > 1:
        recording_length = int(sys.argv[1])
    else:
        recording_length = 10

    # open the NIA, or exit with a failure code
    nia = NIA.NIA()
    if not nia.open():
        sys.exit(1)

    # start collecting data
    milliseconds = 50
    nia_data = NIA.NiaData(nia, milliseconds)

    # warmup - the first few readings seem to be different from the rest
    for i in range(10):
        update(False)

    # recording loop
    start_time = time.time()
    current_time = start_time
    while current_time - start_time < recording_length:
        out_data = update(True)
        current_time = time.time()

    # Print readings
    print out_data

    # close NIA and exit gracefully
    nia.close()
    sys.exit(0)
