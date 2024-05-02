# Janky beacon rebalance

## What it does

Rebalances the beacon effect transmission according to [this discord message](https://discord.com/channels/139677590393716737/1215073493142474833/1234845216339394631) and related [Reddit thread](https://www.reddit.com/r/factorio/comments/1cgv2fm/beacon_rework_for_space_age_andor_20_leaked/).

According to the guestimates the beacon effect transmission will be calculated based on how many beacons affect one assembler using the formula `1/sqrt(n)` where `n` is the number of beacons affecting that machine.

Assuming 2x speed module 3 in each beacon, below number of beacons give the following speed boosts in Factorio 1.1 vs 2.0:

| Beacons | 1.1   | 2.0   |
| ------- | ----- | ----- |
| 1       | +50%  | +100% |
| 2       | +100% | +141% |
| 3       | +150% | +173% |
| 4       | +200% | +200% |
| 5       | +250% | +223% |
| 6       | +300% | +244% |
| 7       | +350% | +264% |
| 8       | +400% | +282% |

## How it works

In factorio 1.1 it is not possible to dynamically change the effect transmission of a beacon entity in-game nor is it possible to dynamically change the beacon effect per machine. In order to mimic the new beacon mechanics some tricks had to be implemented.

This mod adds 24 'janky beacon' entities, each with their hard-coded calculated effect transmission. When for example an assembler is surrounded by 3 beacons, each beacon is replaced by the 'janky beacon (x3)' variant with an effect transmission of `1/sqrt(3) = 0.577`. When a 4th beacon is placed all beacons are then replaced by the 'janky beacon (x4)' variant with an effect transmission of `1/sqrt(4) = 0.5`.

Since there can only be one type of 'janky beacon' be placed choices have to be made. In case one beacon affects two machines, this mod picks the machine with the most beacons surrounding it to determine the effect transmission factor.

The 'janky beacon' entity and item variants can't be crafted or mined. On mining/pipette'ing the mod replaces the entity with a regular beacon. This is to prevent inventory clutter and to ensure manufacturability compatibility.

Only works with the vanilla beacon. Works with all entities that are of type "assembling-machine", "mining-drill", "lab" or "rocket-silo".

## Known issues

On copy/paste of a 'janky beacon' the ghost is replaced with a regular 'beacon' ghost, so that bots can build it. However on replacing the ghost the module information of the 'janky beacon' ghost gets lost.

Moving of buildings with mods like [Picker Dollies](https://mods.factorio.com/mod/PickerDollies) does not update the beacons
