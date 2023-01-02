#!/bin/sh
exec keyring get ansible default --keyring-backend keyring.backends.SecretService.Keyring
