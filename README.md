# MaizeGO

This R package imports GO annotations for maize from several sources and processes them for use in downstream applications.  The intent of this package is to 1) provide reproducable and documented process for cleaning a limited few raw, publically available GO annotation datasets to make them consistent and well formatted and 2) present this package in such a way that the data can be easily imported and incorporated into later applications.  In addition, having "pre-cleaned" the data means that downstream applications can be run much faster since they don't have to clean this dataset with each run.

## Getting Started

This R project produces data files that are intended to be imported into other projects using [devtools](https://www.r-project.org/nosvn/pandoc/devtools.html).

```
library(devtools)
install_github("jrwalsh/MaizeGO", force = TRUE)
data("MaizeGO.B73.v4", package = "MaizeGO")
View(MaizeGO.B73.v4)
```

You can import the latest version of this package using:
```
install_github("jrwalsh/MaizeGO", force = TRUE)
```

Or you can use a specific release:
```
install_github("jrwalsh/MaizeGO@v0.2.1", force = TRUE)
```

## Prerequisites

This code was produced with R v3.4.3 "Kite-Eating Tree". You will need [R](https://www.r-project.org/) and an R editor such as [RStudio](https://www.rstudio.com/). You will need [devtools](https://www.r-project.org/nosvn/pandoc/devtools.html) in order to import these datasets. 

Install devtools from inside the R command console:
```
install.packages("devtools")
```

## Datasets

This package contains 

1) GO Annotations assigned in source to B73v3 gene models
2) GO Annotations assigned in source to B73v4 gene models
3) GO Annotations assigned in source to UniProt protein accessions

You can view the available data objects and their descriptions by using:
```
data(package = "MaizeGO")
```

You can view the help file by using:
```
help(package=MaizeGO)
```

## Troubleshooting and Additional Considerations

This package uses TopGO, which I've found occasionally conflicts with tidyr/dplyr. While developing, sometimes code that previously worked will stop working until RStudio is reset (thus unlinking the imported libraries from the environment). Commands that have been giving me trouble include "View" and "select", for example. This problem is one of the benefits of moving this GO processing to its own package, so this conflict is quarantined in this package and doesn't cause problems in downstream packages.

The "with" and "qualifier" columns are provided "as is".  Be warned they are rough and inconsistently formatted.

Be aware that while efforts were made to ensure the B73v3 ids were in fact v3 ids and not v2 ids (or v1 ids? some of the source data is old enough that it is possible), it is possible that some "GRMZM" ids found here will not be in the v3 assembly (if they were deleted in v3) and some v3 ids will not show up in this package (if the original data was annotated to v2 and the gene model is new in v3).

Finally, this dataset has the potential for duplications in 2 less obvious ways besides a strictly duplicated line:
1) The a GO annotation is made to a gene under both a "COMP" and "EXP" evCode.  General practice would have the higher quality "EXP" annotation replace the lower quality "COMP" annotation.
2) GO is an ontology, and as such has the potential for various levels of granularity in annotation.  This package does not prevent the redundancy that might occur if both a more granular and less granular term were assigned to the same gene. It would be otherwise appropriate to replace the less granular term with the more granular one.

## Authors

* **Jesse R. Walsh** - [jrwalsh](https://github.com/jrwalsh)

## Acknowledgments

* Ethy Cannon and Mary Schaeffer for providing the GO annotation files and for providing guidance regarding the cleaning and formatting of this data.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
