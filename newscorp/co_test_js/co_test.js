#!/usr/bin/env node
const argparse = require('argparse');
const fs = require('fs-extra');

const VIP_PLUGINS = process.env['VIP_PLUGINS'];
const VIPGO_PLUGINS = process.env['VIPGO_PLUGINS'];
const SSH_KEY = '/Users/sleed/.ssh/id_rsa'
const SSH_PUB = SSH_KEY + '.pub';

// @TODO use common-errors
class NotImplementedError extends Error {
  constructor(message) {
    super(message); // (1)
    this.name = "NotImplementedError"; // (2)
  }
}

async function main(args) {
  let plugins_folder = VIP_PLUGINS;

  if (args.vipgo) {
    plugins_folder = VIPGO_PLUGINS;
  }
  let plugin_names = fs.readdirSync(plugins_folder);

  if (args.plugins) {
    throw new NotImplementedError;
  }

  console.log(`Setting branch "${args.branch}" for ${plugin_names.length} plugins in "${plugins_folder}"...`);
  console.log(plugin_names);

  let co = new Checkouter(args.branch, plugins_folder, args.force);
  let promises = [];
  for (let plugin_name of plugin_names) {
    //if (plugin_name !== 'authoring') continue;
    promises.push(co.checkout_branch(plugin_name));
  }
  try {
    await Promise.all(promises);
  } catch (e) {
    console.log(e);
  }
  console.log('OK.');
}


parser = argparse.ArgumentParser({description: 'Checkout test folders of plugin'});
parser.addArgument(['branch'], {help: 'branch to select', defaultValue: 'test'});
parser.addArgument(['--force', '-f'], {action: 'storeTrue', help: 'dont stash'});
parser.addArgument(['--vipgo'], {action: 'storeTrue', help: 'use VIP Go plugins folder instead'});
parser.addArgument(['--plugins', '-p'], {nargs: '+', help: 'plugins to pass'});
main(parser.parseArgs())