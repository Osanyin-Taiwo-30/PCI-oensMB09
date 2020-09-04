#! /bin/bash

export inctime=${HOME}/bin/inctime

export bpath=/cray_home/carlos_bastarz/oensMB09_test_preXC50/run

Procs=(recanl rdpert decanl model2d recfct eof deceof model15d pos15d gribmap)

export datai=2020080100
export dataf=2020083100

export data=${datai}

while [ ${data} -le ${dataf} ]
do
  
  datafct48h=$(${inctime} ${data} +48hr %y4%m2%d2%h2)
  datafct15d=$(${inctime} ${data} +15dy %y4%m2%d2%h2)

  for proc in ${Procs[@]}
  do

    echo ${data} ${datafct48h} ${datafct15d} ${proc}

    if [ ${proc} == "recanl" ]; then ${bpath}/run_recanl.sh TQ0126L028 SMT ANLSMT ${data}; wait; fi
    if [ ${proc} == "rdpert" ]; then ${bpath}/run_rdpert.sh TQ0126L028 SMT YES ${data} 7; wait; fi
    if [ ${proc} == "decanl" ]; then ${bpath}/run_decanl.sh TQ0126L028 SMT YES ${data} 7; wait; fi

    if [ ${proc} == "model2d" ]
    then 
      ${bpath}/run_model.sh 48 4 6 TQ0126L028 SMT ${data} ${datafct48h} CTR 2 1 &
      ${bpath}/run_model.sh 48 4 6 TQ0126L028 SMT ${data} ${datafct48h} RDP 2 7
    fi
    wait

    if [ ${proc} == "recfct" ]
    then 
      ${bpath}/run_recfct.sh TQ0126L028 CTR ${data} &
      ${bpath}/run_recfct.sh TQ0126L028 7 ${data}
    fi
    wait

    if [ ${proc} == "eof" ]; then ${bpath}/run_eof.sh TQ0126L028 7 YES ${data} SMT; wait; fi
    if [ ${proc} == "deceof" ]; then ${bpath}/run_deceof.sh TQ0126L028 EOF YES ${data} 7 SMT; wait; fi

    if [ ${proc} == "model15d" ]
    then
      ${bpath}/run_model.sh 48 4 6 TQ0126L028 SMT ${data} ${datafct15d} NMC 2 1 &
      ${bpath}/run_model.sh 48 4 6 TQ0126L028 SMT ${data} ${datafct15d} NPT 2 7 &
      ${bpath}/run_model.sh 48 4 6 TQ0126L028 SMT ${data} ${datafct15d} PPT 2 7 
    fi
    wait

    if [ ${proc} == "pos15d" ]
    then
      ${bpath}/run_pos.sh 48 4 6 TQ0126L028 ${data} ${datafct15d} NMC &
      ${bpath}/run_pos.sh 48 4 6 TQ0126L028 ${data} ${datafct15d} NPT 7 &
      ${bpath}/run_pos.sh 48 4 6 TQ0126L028 ${data} ${datafct15d} PPT 7 
    fi
    wait

    if [ ${proc} == "gribmap" ]
    then
      ${bpath}/run_gribmap.sh TQ0126L028 ${data} 1 NMC &
      ${bpath}/run_gribmap.sh TQ0126L028 ${data} 7 NPT &
      ${bpath}/run_gribmap.sh TQ0126L028 ${data} 7 PPT 
    fi
    wait

  done

  data=$(${inctime} ${data} +1dy %y4%m2%d2%h2)

done

exit 0
