#!/bin/bash


DNS=""
FILE=""
IP=""
MASK=""
DEBUG=""


usage() 
{
  echo "Usage: $0 <ipaddress> <mask> [OPTIONS]"
  echo "Options:"
  echo " -h --help      Display this help message"
  echo " -s --server    Specify a dns server address"
  echo " -o --output    Save output to file"
  echo " -d --debug     Enable debug mode"
  echo
  echo "For example:"
  echo "$0 10.10.10.10 30"
  echo "$0 192.168.1.0 24 -d 192.168.1.1 -f output.txt"
  echo
}


ip2int()
{
  local a b c d
  { IFS=. read a b c d; } <<< $1
  echo $(((((((a << 8) | b) << 8) | c) << 8) | d))
}


int2ip()
{
  local ui32=$1; shift
  local ip n
  for n in 1 2 3 4; do
    ip=$((ui32 & 0xff))${ip:+.}$ip
    ui32=$((ui32 >> 8))
  done
  echo $ip
}


broadcast()
{
  local addr=$(ip2int $1); shift
  local mask=$((0xffffffff << (32 - $1))); shift
  int2ip $((addr | ~mask))
}


network()
{
  local addr=$(ip2int $1); shift
  local mask=$((0xffffffff << (32 - $1))); shift
  int2ip $((addr & mask))
}


get_all_addresses_in_network()
{
  ((network_int=$(ip2int $(network $1 $2))+1));
  ((broadcast_int=$(ip2int $(broadcast $1 $2))-1));
  for i in $(seq $network_int $broadcast_int)
  do
    int2ip $i;
  done 
}


reverse_dns_host()
{
  trap ctrl_c INT
  if [[ -n $DEBUG ]]
  then    
    host $1 $DNS
  else
    host $1 $DNS | grep "domain name pointer " \
    |  awk -F'.' '{printf $4"."$3"."$2"."$1" ";  for (i=5; i<=NF-1; i++) printf $i".";}' \
    | awk '{print $1"\t"$NF}' |  rev | cut -c2- | rev
  fi
}

function ctrl_c() {
  echo "Ctrl+C detected. Cleaning up and exiting." 1>&2
  exit 1
}

reverse_dns_scan()
{
  for i in $(get_all_addresses_in_network $1 $2)
  do
    reverse_dns_host $i; 
  done
}


valid_ip()
{
  local  ip=$1
  local  stat=1
  if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]
  then
    OIFS=$IFS
    IFS='.'
    ip=($ip)
    IFS=$OIFS
    [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
    stat=$?
  fi
  return $stat
}


exit_abnormal() {
  usage
  exit 1
}


main(){
  if (( $MASK == 31 ))
  then
    reverse_dns_host $(network $IP $MASK)
    reverse_dns_host $(broadcast $IP $MASK)
  elif (( $MASK == 32 ))
  then
    reverse_dns_host $IP
  else
    reverse_dns_scan $IP $MASK
  fi 
}


while [[ $# -gt 0 ]]
do
  case $1 in
    -h|--help)
      exit_abnormal
      ;;
    -d|--debug)
      DEBUG="true"
      shift
      ;;
    -s|--server)
      DNS=$2
      if valid_ip $DNS
      then
        :
      else
        echo "Invalid DNS value ($DNS) should be ip address" 
        exit_abnormal
      fi
      shift 2
      ;;
    -o|--output)
      FILE=$2
      shift 2
      ;;
    *)
      IP="$1"
      MASK="$2"
      if valid_ip $IP
      then
        :
      else
        echo "Invalid IP value ($IP) should be ip address" 
        exit_abnormal
      fi
      if ! [[ $MASK =~ ^[0-9]+$ ]]
      then
        echo "Invalid mask value ($MASK)" 
        exit_abnormal
      fi
      if ! (( a >= 0 && $MASK <= 32 ))
      then
        echo "Invalid mask value ($MASK)" 
        exit_abnormal
      fi
      shift 2
      ;;
  esac
done

if ! [[ -n $IP && -n $MASK ]]
then
  echo "You should set ip and mask value"
  exit_abnormal
fi

if ! [[ -n $DNS ]]
then
  DNS=$(cat /etc/resolv.conf  | grep -v "#" | grep "nameserver" | head -n 1 | cut -d" " -f2)
fi

if [[ -n $FILE ]]
then
  main | tee $FILE
else
  main
fi