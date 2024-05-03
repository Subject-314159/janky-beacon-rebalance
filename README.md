# Janky beacon rebalance

## What it does

Rebalances the beacon effect transmission according to [FFF-409](https://factorio.com/blog/post/fff-409).

Originally inspired by [this discord message](https://discord.com/channels/139677590393716737/1215073493142474833/1234845216339394631) and related [Reddit thread](https://www.reddit.com/r/factorio/comments/1cgv2fm/beacon_rework_for_space_age_andor_20_leaked/).

The beacon effect transmission will be calculated based on how many beacons affect one assembler using the formula `1/sqrt(n)` where `n` is the number of beacons affecting that machine. With the new quality system the base beacon effect transmission ranges from x1.5 to x2.5.

A picture says more than a thousand words:
![Factorio 1.1 vs Factorio 2.0 beacon effects](https://cdn.factorio.com/assets/blog-sync/fff-409-beacon-numbers.png)

## How it works

In factorio 1.1 it is not possible to dynamically change the effect transmission of a beacon entity in-game nor is it possible to dynamically change the beacon effect per machine. In order to mimic the new beacon mechanics some tricks had to be implemented.

This mod adds 24 'janky beacon' entities for each of the 5 quality tiers, each with their hard-coded calculated effect transmission. When for example an assembler is surrounded by 3 legendary beacons, each beacon is replaced by the 'janky beacon (x3) (legendary)' variant with an effect transmission of `2.5 * 1/sqrt(3) = 1.44`. When a 4th beacon is placed all beacons are then replaced by the 'janky beacon (x4) (legendary)' variant with an effect transmission of `2.5 * 1/sqrt(4) = 1.25`.

Mixing of different quality tier beacons is possible. One legendary beacon and two rare beacons will result in one 'janky beacon (x3) (legendary)' and two 'janky beacon (x3) (rare)'. This is because the machine is surrounded by three beacons, so each beacon will be the (x3) variant.

Since there can only be one type of 'janky beacon' entity that affects all machines, choices have to be made. In case one beacon affects two machines, this mod picks the machine with the most beacons surrounding it to determine the effect transmission factor.

The 'janky beacon' entity and item variants can't be crafted or mined. On mining/pipette'ing the mod replaces the entity with a regular beacon. This is to prevent inventory clutter and to ensure manufacturability compatibility.

Only works with the vanilla beacon. Works with all entities that are of type "assembling-machine", "mining-drill", "lab" or "rocket-silo".

## Known issues

On copy/paste of a 'janky beacon' the ghost is replaced with a regular 'beacon' ghost, so that bots can build it. However on replacing the ghost the module information of the 'janky beacon' ghost gets lost.

Moving of buildings with mods like [Picker Dollies](https://mods.factorio.com/mod/PickerDollies) does not update the beacons
