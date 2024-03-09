import urllib.request
import json
import subprocess
import os
import os.path as path
import hashlib
import base64
import random
import string

main_formula_name = input("Formula to add (along with it's dependencies): ")

github_repository = 'manelatun/homebrew-catalina-bottles'
github_release_tag = ''.join(random.choices(string.ascii_lowercase + string.digits, k=8))

print(f"\nYour GitHub release tag: {github_release_tag}")
print("After committing the changes, create a release with this name.\n")

base_path = os.getcwd()
formula_path = path.join(base_path, 'Formula')
bottles_path = path.join(base_path, 'Bottles')
os.makedirs(formula_path, exist_ok=True)
os.makedirs(bottles_path, exist_ok=True)

print("Tapping 'homebrew/core'...")
subprocess.run(['brew', 'tap', 'homebrew/core', '--force'])

# ==================================== #

brew_formula_data = {}

def fetch_formula_deps(formula_name: str):
  if not brew_formula_data.get(formula_name):
    print(f'Sending request to: https://formulae.brew.sh/api/formula/{formula_name}.json')
    with urllib.request.urlopen(f'https://formulae.brew.sh/api/formula/{formula_name}.json') as response:
      brew_formula_data[formula_name] = json.loads(response.read())
  formula_data = brew_formula_data[formula_name]
  return formula_data['dependencies'] + formula_data['build_dependencies']

def formula_dependencies_duped(formula_name: str):
  dependencies = fetch_formula_deps(formula_name)
  if not dependencies: return [formula_name]
  else:
    res = []
    for dep in dependencies:
      res += formula_dependencies_duped(dep)
    return res + [formula_name]

def formula_dependencies(formula_name: str):
  formula = []
  for dep in formula_dependencies_duped(formula_name):
    if dep not in formula:
      formula += [dep]
  return formula

print('Fetching dependencies...')
formulas = formula_dependencies(main_formula_name)

# ==================================== #

class File:
  def __init__(self, path: str) -> None:
    self.path = path

  def read(self):
    with open(self.path, 'r') as f:
      return f.read()
  
  def write(self, content):
    with open(self.path, 'w') as f:
      f.write(content)

def find_bottles(text: str):
  bottles_begin = text.index('bottle do')
  bottles_end = text.index('end', bottles_begin + 9) + 3
  return bottles_begin, bottles_end

print('Installing and building bottles...')

for formula in formulas:
  print(f'Processing {formula}...')

  local_path = path.join(formula_path, formula + '.rb')
  source_path_prefix = formula[:1] if not formula.startswith('lib') else 'lib'
  source_path = path.join(base_path, 'homebrew-core', 'Formula', source_path_prefix, formula + '.rb')

  if not path.exists(source_path):
    print(f"{formula} does not exist on 'homebrew-core'.")
    continue

  source_content = File(source_path).read()
  source_hash = base64.b64encode(hashlib.sha256(source_content.encode()).digest()).decode('utf-8')

  # Clean formula
  subprocess.run(['brew', 'uninstall', formula, '--ignore-dependencies'], capture_output=True)
  subprocess.run(['brew', 'uninstall', f'{github_repository}/{formula}', '--ignore-dependencies'], capture_output=True)

  # Check if formula is up-to-date.
  if path.exists(local_path) and File(local_path).read()[9:53] == source_hash:
    print(f'{formula} is already up-to-date.')
    # Install from bottle for dependents.
    subprocess.run(['brew', 'install', f'{github_repository}/{formula}'])
    continue

  # Build bottle
  build = subprocess.run(['brew', 'install', formula, '--build-bottle', '--ignore-dependencies'])
  if build.returncode != 0: exit(1)

  # Create bottle
  bottles = subprocess.run(['brew', 'bottle', formula, '--root-url', f'https://github.com/{github_repository}/releases/download/{github_release_tag}/', '--quiet'], cwd=bottles_path, capture_output=True).stdout
  bottles_begin, bottles_end = find_bottles(bottles)
  bottles = bottles[bottles_begin:bottles_end]

  subprocess.run(['brew', 'postinstall', formula])

  # Prepend hash
  source_content = f'# SHA256:{source_hash}\n\n' + source_content

  # Add placeholder
  bottles_begin, bottles_end = find_bottles(source_content)
  source_content = source_content[:bottles_begin] + bottles + source_content[bottles_end:]

  # Swap dependencies to bottles
  source_content = source_content.replace('depends_on "', f'depends_on "{github_repository}/')

  # Write formula
  File(local_path).write(source_content)
  print(f"Copied {formula} from 'homebrew-core'.")

# ==================================== #

# Final cleanup
formulas.reverse()
for formula in formulas:
  subprocess.run(['brew', 'uninstall', formula], capture_output=True)
  subprocess.run(['brew', 'uninstall', f'{github_repository}/{formula}'], capture_output=True)
