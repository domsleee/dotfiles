#!/usr/bin/env python3
import argparse
from shell import shell
import os
import time
from multiprocess import Multiprocess, multiprocess, Queue

VIP_PATH = os.getenv('VIP')
VIPGO_PATH = os.getenv('VIPGO')
PLUGINS_FOLDER = os.path.join(VIP_PATH, 'www/wp-content/themes/vip/newscorpau-plugins/')
#PLUGINS_FOLDER = '/Users/sleed/Documents/vip-go-skeleton/src/wp-content/plugins/newscorpau-plugins'

def main(args):
  resultQ = Queue()
  plugins_folder = PLUGINS_FOLDER
  if args.vipgo:
    plugins_folder = os.path.join(VIPGO_PATH, 'src/wp-content/plugins/newscorpau-plugins')

  plugin_names = os.listdir(plugins_folder)

  print(f'Setting branch "{args.branch}" for {len(plugin_names)} plugins...\n')
  print(sorted(plugin_names))
  multiprocess(worker, [(plugin_name, plugins_folder, resultQ, args.branch, args.force,)
                        for plugin_name in plugin_names])

  results = flush_results(resultQ)
  print('done')
  print('RESULTS\n' + '='*64)
  print('\n'.join(results))


def worker(plugin_name, plugins_folder, resultQ, branch, force):
  res = []
  res = res + [plugin_name, '-'*32]
  plugin_path = os.path.join(plugins_folder, plugin_name)
  shell(f'git -C "{plugin_path}" checkout --track "origin/{branch}"')
  status = shell(f'git -C "{plugin_path}" status -s').output()
  if status != []:
    #print(status)
    shell(f'git -C "{plugin_path}" add -A')
    if force or only_phpcs(status):
      if force:
        res.append(f'Force, not stashing...')
      else:
        res.append(f"only phpunit and phpcs")
      shell(f'git -C "{plugin_path}" reset --hard HEAD')
    else:
      res.append('*** stashing changes ***')
      shell(f'git -C "{plugin_path}" stash push -m "Auto by co_test"')
  shell(f'git -C "{plugin_path}" checkout "{branch}"')

  # TODO.
  no_pull = False
  if not no_pull:
    outo = shell(f'git -C "{plugin_path}" pull').output()
    if len(outo) and outo[0] != 'Already up to date.':
      res += outo

  if len(res) > 2:
    resultQ.put('\n'.join(res))

def only_phpcs(status):
  return all('phpcs' in line or 'phpunit' in line for line in status)

def flush_results(resultQ):
  results = []
  while not resultQ.empty():
    results.append(resultQ.get())
  return results


if __name__ == '__main__':
  parser = argparse.ArgumentParser(description='Checkout test folders of plugin')
  parser.add_argument('branch', help='branch to select', default='test')
  parser.add_argument('--force', '-f', action='store_true', help='dont stash')
  parser.add_argument('--vipgo', action='store_true', help='use VIP Go plugins folder instead')
  main(parser.parse_args())
