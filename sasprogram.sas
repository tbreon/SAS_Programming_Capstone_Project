/*PROC MEANS DATA=cars;
   VAR MPG_City Weight;  
RUN;*/

/* Define the SAS macro named summary_stats */
%macro summary_stats(dataset, make_filter=);
    /* PROC MEANS to calculate summary statistics */
    proc means data=&dataset;
        /* Specify the numerical variables for which to calculate summary statistics */
        var MPG_City weight;
        
                /* Filter data based on make_filter macro variable */
        %if %length(&make_filter) %then %do;
            where make = "&make_filter";
            title "Summary Statistics for &make_filter Vehicles";
        %end;
        
        /* Output options */
        output out=summary_stats
               mean=mean_median
               median=median_median
               n=n_total
               std=std_dev;
    run;
%mend summary_stats;

/*Assign the dataset name to a macro variable using %let */
%let dataset = cars;

/* Assign the make filter to a macro variable using %let */
%let make_filter = Chevrolet;

/* Call the macro and provide the macro variable names (&dataset and &make_filter) as arguments */
%summary_stats(dataset=&dataset, make_filter=&make_filter);

