#!/usr/bin/env python3
import argparse
import multiprocessing
from shell import shell
import os
from tqdm import tqdm
import time

VIP_PATH = os.getenv('VIP')
PLUGINS_FOLDER = os.path.join(VIP_PATH, 'www/wp-content/themes/vip/newscorpau-plugins/')

def main(args):
  m = multiprocessing.Manager()
  resultQ = m.Queue()
  plugin_names = os.listdir(PLUGINS_FOLDER)
  print(f'Setting branch "{args.branch}" for {len(plugin_names)} plugins...\n')
  print(sorted(plugin_names))

  #for plugin_name in plugin_names:
  #  worker_f(plugin_name, resultDone, resultQ, args.branch, args.force)
  #return

  pbar = tqdm(total=len(plugin_names))

  pool = multiprocessing.Pool()
  #[pool.apply_async(worker_f, (plugin_name, resultDone, resultQ, args.branch, args.force, ))
  #  for plugin_name in plugin_names]
  for _ in enumerate(pool.imap_unordered(worker_f, [(plugin_name, resultQ, args.branch, args.force, )
    for plugin_name in plugin_names])):
      pbar.update(1)
  
  pool.close()
  pool.join()
  pbar.close()
  
  results = flush_results(resultQ)
  print('done')
  print('RESULTS\n' + '='*64)
  print('\n'.join(results))

def worker_f(args):
  try:
    worker(*args)
  except Exception as e:
    print(e)

def worker(plugin_name, resultQ, branch, force):
  # logic in here
  res = []
  res = res + [plugin_name, '-'*32]
  plugin_path = os.path.join(PLUGINS_FOLDER, plugin_name)
  #print(plugin_path, branch)
  shell(f'git -C "{plugin_path}" checkout --track "origin/{branch}"')
  status = shell(f'git -C "{plugin_path}" status -s').output()
  if status != []:
    #print(status)
    shell(f'git -C "{plugin_path}" add -A')
    if force or not_only_phpcs(status):
      if force:
        res.append(f'Force, not stashing...')
      else:
        res.append(f"only phpunit and phpcs")
      shell(f'git -C "{plugin_path}" reset HEAD --hard')
    else:
      res.append('*** stashing changes ***')
      shell(f'git -C "{plugin_path}" stash push -m "Auto by co_test"')
  shell(f'git -C "{plugin_path}" checkout "{branch}"')
  outo = shell(f'git -C "{plugin_path}" pull').output()
  if len(outo) and outo[0] != 'Already up to date.':
    res += outo

  if len(res) > 2:
    resultQ.put('\n'.join(res))


def not_only_phpcs(status):
  for line in status:
    if 'phpcs' not in line and 'phpunit' not in line:
      return True
  return False

def flush_results(resultQ):
  results = []
  while not resultQ.empty():
    results.append(resultQ.get())
  return results


if __name__ == '__main__':
  parser = argparse.ArgumentParser(description='Checkout test folders of plugin')
  parser.add_argument('branch', help='branch to select', default='test')
  parser.add_argument('--force', '-f', action='store_true', help='dont stash')
  main(parser.parse_args())