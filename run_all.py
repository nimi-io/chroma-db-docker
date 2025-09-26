import multiprocessing
from chroma_server import start_chroma
from smol_server import start_smol

if __name__ == "__main__":
    p1 = multiprocessing.Process(target=start_chroma)
    p2 = multiprocessing.Process(target=start_smol)
    p1.start()
    p2.start()
    p1.join()
    p2.join()
