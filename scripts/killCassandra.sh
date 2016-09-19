#!/bin/bash



NOVA=$GOPATH/src/github.com/Novetta

echo "Shutting Down Cassandra"
sudo service cassandra stop
sudo fuser 7000/tcp
sudo pkill -f CassandraDaemon
sleep 10

echo "Deleteing Videx Chunks"
rm -rf $HOME/videx


cd /var/lib/cassandra

echo "Removing commit log"
cd commitlog
sudo rm -rf *
cd ..

echo "Removing Data Dir"
cd data
sudo rm -rf *
cd ..

echo "Removing saved caches"
cd saved_caches
sudo rm -rf *
cd ..

echo "Starting Cassndra"
sudo service cassandra start

echo "Waiting 20 Secs for Cassandra"
sleep 20



echo "Init Search"

cd $NOVA/common
git pull
git submodule sync
git pull

cd aide/search/setup
bash updateDb.sh


echo "Init Videx"

cd $NOVA/VideoEnterprise/videx2/setup
#cqlsh -f setup_cassandra.cql
#cqlsh -f init_migrate.cql
bash updateDb.sh

echo "Executor Tables"
cqlsh -f $NOVA/common/executor/distexecutor/setup/setup_cassandra.cql

echo "Adding Sample Data to Videx"
cd ../dev
cqlsh -f sample_data.cql

echo "Bootdtraping anonymous to ADMIN"
cqlsh -f bootstrap_role.cql


echo "Init Ares"

cd $NOVA/pwcop/setup
#cqlsh -f setup_cassandra.cql
#cqlsh -f init_migrate.cql
bash updateDb.sh

echo "Bootstraping Role"
cd ../dev
cqlsh -f bootstrap_role.cql


echo "Init ITK"

cd $NOVA/ITK/setup
cqlsh -f setup_cassandra.cql
#cqlsh -f init_migrate.cql
#bash updateDb.sh

echo "Bootstraping Role"
cd ../dev
cqlsh -f bootstrap_role.cql

echo "Adding Sample Data"
bash populate_records.sh






