# PyFriso

## usage
```python
from friso import Friso, Task, Config, StringSplit
import friso

f = Friso()
t = Task()
c = Config()

f.init_from_ifile(c, "friso.ini")
c.set_mode(friso.MODE_COMPLEX)
t.set_text("分词的文本")
while c.next_token(f, t):
    print(t.token.rlen)
    print(t.token.word.decode())
    print(t.token.offset)
    print(t.token.length)
    print("-----------------------")

sp =  StringSplit(b",", b",I am a chinese,,my name is Lion,and i am the author of friso,bug report email chenxin619315@gmail.com,qq:1187582057")
buffer = bytearray(128)
while sp.split_next(buffer) is not None:
    print(buffer)
```
