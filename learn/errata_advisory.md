# Errata and Advisory

## Doc

From Mike: [Highlevel overview](https://mojo.redhat.com/docs/DOC-1170906) and [Details](https://mojo.redhat.com/docs/DOC-927875)
* There is automation for RPM Advisory step 0. and step 3.
* There is automation for Image Advisory step 3.

## Intro

dictionary.com:

* [Errata](https://www.dictionary.com/browse/errata) is originally the plural of the singular Latin noun erratum. Like many such borrowed nouns ( agenda; candelabra ), it came by the mid-17th century to be used as a singular noun, meaning “a list of errors or corrections to be made (in a book).”
* [Advisory](https://www.dictionary.com/browse/advisory): an announcement or bulletin that serves to advise and usually warn the public, as of some potential hazard

At Red Hat, [errata of products](https://access.redhat.com/errata/#/) are composed of advisories of 3 types: 

* [RHBA-2018:3620 - Bug Fix Advisory](https://access.redhat.com/errata/RHBA-2018:3620)
* [RHEA-2018:3585 - Product Enhancement Advisory](https://access.redhat.com/errata/RHEA-2018:3585)
* [RHSA-2018:2709 - Security Advisory](https://access.redhat.com/errata/RHSA-2018:2709)


## [Errata tool](https://errata.devel.redhat.com/)

An example of advisory in errata tool: 

By it content type, an advisory can be

* [RHSA-2013:0220-19: RPM advisory](https://errata.devel.redhat.com/advisory/14345) if it has `RPMDiff` tab.
* [RHBA-2016:2065-06: Text only Advisory](https://errata.devel.redhat.com/advisory/25199) if it has neither `RPMDiff` tab nor `Container` tab.
* [RHBA-2017:28429-03: Image advisory](https://errata.devel.redhat.com/advisory/28429) if it has `Container` tab.

Note that an advisory could be both PRM and Image advisory.

Status: `NEW_FILES` &#8658; `QE` &#8658; `REL_PREP` &#8658; `PUSH_READY` &#8658; `SHIPPED_LIVE`.

In general, QE is responsible for an advisory when it is in `QE` status. 

Depending on its type, an advisory has different `Approval Progress`. See `Summary` tab.

Qs:
1. How do we get notified when we need to work on an advisory?
2. How do we search the corresponding image advisory for an RPM one?
3. Where/how to run the tests for advisory? Where to get help if something is not working.

TODO
* Practice on advisory with each type. Be familiar with
    * the testing env.
    * debugging/troubleshooting steps, and
    * automation.

