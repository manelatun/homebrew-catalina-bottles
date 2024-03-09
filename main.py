#!/usr/bin/python3

print()
main_formula_name = input('Formula to add: ')
print()

from utils import get_random_release_tag

GITHUB_REPOSITORY = 'manelatun/homebrew-catalina-bottles'
GITHUB_RELEASE_TAG = get_random_release_tag(8)
HOMEBREW_REPOSITORY = GITHUB_REPOSITORY.replace('homebrew-', '')

# =========== Create directories =========== #

import os
import os.path as path

base_path = os.getcwd()
formula_path = path.join(base_path, 'Formula')
bottles_path = path.join(base_path, 'Bottles')
os.makedirs(formula_path, exist_ok=True)
os.makedirs(bottles_path, exist_ok=True)

# =========== Prepare Homebrew =========== #

import subprocess

print("Tapping homebrew/core.")
subprocess.run(
  args=['brew', 'tap', 'homebrew/core', '--force'],
  stdout=subprocess.DEVNULL
)

print("Updating Homebrew's taps.")
subprocess.run(
  args=['brew', 'update'],
  stdout=subprocess.DEVNULL
)

print("Updating the 'homebrew-core' submodule.")
subprocess.run(
  args=['git', 'submodule', 'update', '--recursive'],
  stdout=subprocess.DEVNULL
)

print()

# =========== Initial cleanup =========== #

import glob

print("Cleaning up previous bottles.")
for bottle in glob.glob(path.join(bottles_path, '*.bottle.*')):
  os.remove(bottle)

print()

# =========== Dependency resolution =========== #

import urllib.request
import json

brew_formula_cache = {}

# Get direct dependencies of a formula.
def brew_fetch_direct_dependencies(formula_name: str):
  formula_data = brew_formula_cache.get(formula_name)
  if not formula_data:
    print(formula_name + ' ' * 12, end='\r')
    with urllib.request.urlopen(f'https://formulae.brew.sh/api/formula/{formula_name}.json') as response:
      formula_data = brew_formula_cache[formula_name] = json.loads(response.read())
  return formula_data['dependencies'] + formula_data['build_dependencies']

# Recursively get all dependencies of a formula.
def brew_fetch_all_dependencies(formula_name: str):
  dependencies = brew_fetch_direct_dependencies(formula_name)
  if not dependencies: return [formula_name]
  else:
    res = [brew_fetch_all_dependencies(dependency) for dependency in dependencies]
    return [x for y in res for x in y] + [formula_name] # flatten the list as well!

# Get all dependencies of a formula, ordered and without any duplicates.
def get_dependencies(formula_name: str):
  dependencies = []
  for dependency in brew_fetch_all_dependencies(formula_name):
    if dependency not in dependencies:
      dependencies += [dependency]
  return dependencies

print(f"Fetching {main_formula_name}'s dependencies.")
formulas = get_dependencies(main_formula_name)
print(' '.join(formulas))

# =========== Dependency resolution =========== #

from utils import get_sha256_hash, File

def find_bottles(text: str):
  bottles_begin = text.index('bottle do')
  bottles_end = text.index('end', bottles_begin + 9) + 3
  return bottles_begin, bottles_end

for formula_name in formulas:
  print(f'\nCurrent formula: {formula_name}')

  local_path = path.join(formula_path, formula_name + '.rb')

  source_path_prefix = formula_name[:1] if not formula_name.startswith('lib') else 'lib'
  source_path = path.join(base_path, 'homebrew-core', 'Formula', source_path_prefix, formula_name + '.rb')

  if not path.exists(source_path):
    print(f"{formula_name} does not exist on 'homebrew-core'.")
    exit(1)

  source_content = File(source_path).read()
  source_hash = get_sha256_hash(source_content)

  # Remove formula if already installed
  subprocess.run(
    args=['brew', 'uninstall', formula_name, '--ignore-dependencies'],
    stdout=subprocess.DEVNULL,
    stderr=subprocess.DEVNULL
  )

  # Check if formula is up-to-date and install from bottle if so
  if path.exists(local_path):
    local_hash = File(local_path).read_single_line().replace('# SHA256:', '').strip()
    if local_hash == source_hash:
      print(f"Installing {formula_name} from bottle because it's up-to-date.")
      # Install from bottle for dependents.
      install_result = subprocess.run(
        args=['brew', 'install', f'{HOMEBREW_REPOSITORY}/{formula_name}'],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.STDOUT
      )
      if install_result.returncode != 0: exit(1)
      continue

  # Build bottle
  print(f"Installing {formula_name}")
  build_result = subprocess.run(
    args=['brew', 'install', formula_name, '--build-bottle'],
    stdout=subprocess.DEVNULL,
    stderr=subprocess.STDOUT
  )
  if build_result.returncode != 0: exit(1)

  # Create bottle
  print(f"Creating bottle for {formula_name}")
  bottle_result = subprocess.run(
    args=['brew', 'bottle', formula_name, '--root-url', f'https://github.com/{GITHUB_REPOSITORY}/releases/download/{GITHUB_RELEASE_TAG}/'],
    cwd=bottles_path,
    capture_output=True,
    text=True
  )
  if bottle_result.returncode != 0: exit(1)
  bottles_begin, bottles_end = find_bottles(bottle_result.stdout)
  bottles = bottle_result.stdout[bottles_begin:bottles_end]

  # Remove double dash from bottle names
  for bottle in glob.glob(path.join(bottles_path, '*--*')):
    os.rename(bottle, bottle.replace('--', '-'))

  # Prepend hash
  local_content = f'# SHA256:{source_hash}\n\n' + source_content

  # Replace bottles
  bottles_begin, bottles_end = find_bottles(local_content)
  local_content = local_content[:bottles_begin] + bottles + local_content[bottles_end:]

  # Use dependencies with bottles
  local_content = local_content.replace('depends_on "', f'depends_on "{HOMEBREW_REPOSITORY}/')

  # Write local formula
  File(local_path).write(local_content)
  print(f"Created {formula_name} from 'homebrew-core'.")

# =========== Wrap up =========== #

print('\nCleaning up...')

formulas.reverse()
for formula in formulas:
  subprocess.run(['brew', 'uninstall', formula], capture_output=True)

print()
print('Your GitHub release tag: ' + GITHUB_RELEASE_TAG)
print('Commit & push any changes, create the tag above')
print('and upload the bottles to the release.')
print()
