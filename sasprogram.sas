%macro summary_stats(dataset, make_filter=);
    /* Create a temporary dataset with filtering using PROC SQL */
    %if %length(&make_filter) %then %do;
        proc sql;
            create table temp_filtered as
            select * from &dataset
            where make = "&make_filter";
        quit;
        %let ds_to_use = temp_filtered;
        title "Summary Statistics for &make_filter Vehicles";
    %end;
    %else %let ds_to_use = &dataset;

    /* PROC MEANS to calculate summary statistics */
    proc means data=&ds_to_use;
        /* Specify the numerical variables for which to calculate summary statistics */
        var MPG_City weight;

        /* Output options */
        output out=summary_stats
               mean=mean_median
               median=median_median
               n=n_total
               std=std_dev;
    run;

    /* Cleanup the temporary dataset */
    %if %length(&make_filter) %then %do;
        proc datasets lib=work nolist;
            delete temp_filtered;
        quit;
    %end;
%mend summary_stats;

/*Assign the dataset name to a macro variable using %let */
%let dataset = cars;

/* Assign the make filter to a macro variable using %let */
%let make_filter = Chevrolet;

/* Call the macro and provide the macro variable names (&dataset and &make_filter) as arguments */
%summary_stats(dataset=&dataset, make_filter=&make_filter);
