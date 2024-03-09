import random
import string
import base64
import hashlib

def get_random_release_tag(random_length: int):
  return ''.join(random.choices(string.ascii_lowercase + string.digits, k=random_length))

def get_sha256_hash(data: str):
  return base64.b64encode(hashlib.sha256(data.encode('utf-8')).digest()).decode('utf-8')

class File:
  def __init__(self, path: str) -> None:
    self.path = path

  def read(self):
    with open(self.path, 'r') as f:
      content = f.read()
    return content
  
  def read_single_line(self):
    with open(self.path, 'r') as f:
      content = f.readline()
    return content

  def write(self, content):
    with open(self.path, 'w') as f:
      f.write(content)
