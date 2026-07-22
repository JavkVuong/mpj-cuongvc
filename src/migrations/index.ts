import * as migration_20260720_152322_init from './20260720_152322_init';

export const migrations = [
  {
    up: migration_20260720_152322_init.up,
    down: migration_20260720_152322_init.down,
    name: '20260720_152322_init'
  },
];
