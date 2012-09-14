#!/usr/bin/env bash
#
# Create a PLT for the installed erlang libraries

PURITY_DIR=$(dirname ${BASH_SOURCE[0]})/..

LIBRARIES="appmon asn1 common_test compiler cosEvent cosEventDomain \
           cosFileTransfer cosNotification cosProperty cosTime \
           cosTransactions crypto debugger dialyzer diameter \
           docbuilder edoc eldap erl_docgen erl_interface erts \
           et eunit gs hipe ic inets inviso jinterface kernel \
           megaco mnesia observer odbc orber os_mon otp_mibs \
           parsetools percept pman public_key reltool runtime_tools \
           sasl snmp ssh ssl stdlib syntax_tools test_server toolbar \
           tools tv typer webtool wx xmerl"

${PURITY_DIR}/purity --build-plt --plt erlang_libs.plt --quiet \
    --apps ${LIBRARIES}
