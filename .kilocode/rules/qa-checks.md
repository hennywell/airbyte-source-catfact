# Airbyte connectors QA checks

Copy Page

This document is listing all the static-analysis checks that are performed on the Airbyte connectors. These checks are running in our CI/CD pipeline and are used to ensure a connector is following the best practices and is respecting the Airbyte standards. Meeting these standards means that the connector will be able to be safely integrated into the Airbyte platform and released to registries (DockerHub, Pypi etc.). You can consider these checks as a set of guidelines to follow when developing a connector. They are by no mean replacing the need for a manual review of the connector codebase and the implementation of good test suites.

## 📄 Documentation[​](#-documentation "Direct link to 📄 Documentation")

### Breaking changes must be accompanied by a migration guide[​](#breaking-changes-must-be-accompanied-by-a-migration-guide "Direct link to Breaking changes must be accompanied by a migration guide")

*Applies to the following connector types: source, destination* *Applies to the following connector languages: java, low-code, python, manifest-only* *Applies to connector with any support level* *Applies to connector with 100 internal support level* *Applies to connector with any Airbyte usage level*

When a breaking change is introduced, we check that a migration guide is available. It should be stored under `./docs/integrations/<connector-type>s/<connector-name>-migrations.md`. This document should contain a section for each breaking change, in order of the version descending. It must explain users which action to take to migrate to the new version.

### Connectors must have user facing documentation[​](#connectors-must-have-user-facing-documentation "Direct link to Connectors must have user facing documentation")

*Applies to the following connector types: source, destination* *Applies to the following connector languages: java, low-code, python, manifest-only* *Applies to connector with any support level* *Applies to connector with 100 internal support level* *Applies to connector with any Airbyte usage level*

The user facing connector documentation should be stored under `./docs/integrations/<connector-type>s/<connector-name>.md`.

### Links used in connector documentation are valid[​](#links-used-in-connector-documentation-are-valid "Direct link to Links used in connector documentation are valid")

*Applies to the following connector types: source* *Applies to the following connector languages: python, low-code* *Applies to connector with any support level* *Applies to connector with 300 internal support level* *Applies to connector with any Airbyte usage level*

The user facing connector documentation should update invalid links in connector documentation. For links that are used as example and return 404 status code, use `example: `before link to skip it.

### Connectors documentation headers structure, naming and order follow our guidelines[​](#connectors-documentation-headers-structure-naming-and-order-follow-our-guidelines "Direct link to Connectors documentation headers structure, naming and order follow our guidelines")

*Applies to the following connector types: source* *Applies to the following connector languages: python, low-code* *Applies to connector with any support level* *Applies to connector with 300 internal support level* *Applies to connector with any Airbyte usage level*

The user facing connector documentation should follow the guidelines defined in the [standard template](https://github.com/airbytehq/airbyte/blob/master/airbyte-ci/connectors/connectors_qa/src/connectors_qa/checks/documentation/templates/template.md.j2).

This check expects the following order of headers in the documentation:

```


  # CONNECTOR_NAME_FROM_METADATA

  ## Prerequisites

  ## Setup guide

  ## Set up CONNECTOR_NAME_FROM_METADATA

  ### For Airbyte Cloud:

  ### For Airbyte Open Source:

  ### CONNECTOR_SPECIFIC_FEATURES

  ## Set up the CONNECTOR_NAME_FROM_METADATA connector in Airbyte

  ### For Airbyte Cloud:

  ### For Airbyte Open Source:

  ## CONNECTOR_SPECIFIC_FEATURES

  ## Supported sync modes

  ## Supported Streams

  ## CONNECTOR_SPECIFIC_FEATURES

  ### Performance considerations

  ## Data type map

  ## Limitations & Troubleshooting

  ### CONNECTOR_SPECIFIC_FEATURES

  ### Tutorials

  ## Changelog
```

List of not required headers, which can be not exist in the documentation and their strict check will be skipped:

* Set up the CONNECTOR\_NAME\_FROM\_METADATA connector in Airbyte

* For Airbyte Cloud: (as subtitle of Set up CONNECTOR\_NAME\_FROM\_METADATA)

* For Airbyte Open Source: (as subtitle of Set up CONNECTOR\_NAME\_FROM\_METADATA)

* CONNECTOR\_SPECIFIC\_FEATURES (but this headers should be on a right place according to expected order)

* Performance considerations

* Data type map

* Limitations & Troubleshooting

* Tutorials

### Prerequisites section of the documentation describes all required fields from specification[​](#prerequisites-section-of-the-documentation-describes-all-required-fields-from-specification "Direct link to Prerequisites section of the documentation describes all required fields from specification")

*Applies to the following connector types: source* *Applies to the following connector languages: python, low-code* *Applies to connector with any support level* *Applies to connector with 300 internal support level* *Applies to connector with any Airbyte usage level*

The user facing connector documentation should update `Prerequisites` section with description for all required fields from source specification. Having described all required fields in a one place helps Airbyte users easily set up the source connector. If spec has required credentials/access\_token/refresh\_token etc, check searches for one of \["account", "auth", "credentials", "access", "client"] words. No need to add credentials/access\_token/refresh\_token etc to the section

### Main Source Section of the documentation follows our guidelines[​](#main-source-section-of-the-documentation-follows-our-guidelines "Direct link to Main Source Section of the documentation follows our guidelines")

*Applies to the following connector types: source* *Applies to the following connector languages: python, low-code* *Applies to connector with any support level* *Applies to connector with 300 internal support level* *Applies to connector with any Airbyte usage level*

The user facing connector documentation should follow the guidelines defined in the [standard template](https://github.com/airbytehq/airbyte/blob/master/airbyte-ci/connectors/connectors_qa/src/connectors_qa/checks/documentation/templates/template.md.j2).

Check verifies that CONNECTOR\_NAME\_FROM\_METADATA header section content follows standard template:

```

<HideInUI>

This page contains the setup guide and reference information for the [CONNECTOR_NAME_FROM_METADATA]({docs_link}) source connector.

</HideInUI>
```

### 'For Airbyte Cloud:' section of the documentation follows our guidelines[​](#for-airbyte-cloud-section-of-the-documentation-follows-our-guidelines "Direct link to 'For Airbyte Cloud:' section of the documentation follows our guidelines")

*Applies to the following connector types: source* *Applies to the following connector languages: python, low-code* *Applies to connector with any support level* *Applies to connector with 300 internal support level* *Applies to connector with any Airbyte usage level*

The user facing connector documentation should follow the guidelines defined in the [standard template](https://github.com/airbytehq/airbyte/blob/master/airbyte-ci/connectors/connectors_qa/src/connectors_qa/checks/documentation/templates/template.md.j2).

Check verifies that For Airbyte Cloud: header section content follows standard template:

```

1. [Log into your Airbyte Cloud](https://cloud.airbyte.com/workspaces) account.
2. Click Sources and then click + New source.
3. On the Set up the source page, select CONNECTOR_NAME_FROM_METADATA from the Source type dropdown.
4. Enter a name for the CONNECTOR_NAME_FROM_METADATA connector.
```

### 'For Airbyte Open Source:' section of the documentation follows our guidelines[​](#for-airbyte-open-source-section-of-the-documentation-follows-our-guidelines "Direct link to 'For Airbyte Open Source:' section of the documentation follows our guidelines")

*Applies to the following connector types: source* *Applies to the following connector languages: python, low-code* *Applies to connector with any support level* *Applies to connector with 300 internal support level* *Applies to connector with any Airbyte usage level*

The user facing connector documentation should follow the guidelines defined in the [standard template](https://github.com/airbytehq/airbyte/blob/master/airbyte-ci/connectors/connectors_qa/src/connectors_qa/checks/documentation/templates/template.md.j2).

Check verifies that For Airbyte Open Source: header section content follows standard template:

```

1. Navigate to the Airbyte Open Source dashboard.
```

### 'Supported sync modes' section of the documentation follows our guidelines[​](#supported-sync-modes-section-of-the-documentation-follows-our-guidelines "Direct link to 'Supported sync modes' section of the documentation follows our guidelines")

*Applies to the following connector types: source* *Applies to the following connector languages: python, low-code* *Applies to connector with any support level* *Applies to connector with 300 internal support level* *Applies to connector with any Airbyte usage level*

The user facing connector documentation should follow the guidelines defined in the [standard template](https://github.com/airbytehq/airbyte/blob/master/airbyte-ci/connectors/connectors_qa/src/connectors_qa/checks/documentation/templates/template.md.j2).

Check verifies that Supported sync modes header section content follows standard template:

```

The CONNECTOR_NAME_FROM_METADATA source connector supports the following [sync modes](https://docs.airbyte.com/cloud/core-concepts/#connection-sync-modes):
```

### 'Tutorials' section of the documentation follows our guidelines[​](#tutorials-section-of-the-documentation-follows-our-guidelines "Direct link to 'Tutorials' section of the documentation follows our guidelines")

*Applies to the following connector types: source* *Applies to the following connector languages: python, low-code* *Applies to connector with any support level* *Applies to connector with 300 internal support level* *Applies to connector with any Airbyte usage level*

The user facing connector documentation should follow the guidelines defined in the [standard template](https://github.com/airbytehq/airbyte/blob/master/airbyte-ci/connectors/connectors_qa/src/connectors_qa/checks/documentation/templates/template.md.j2).

Check verifies that Tutorials header section content follows standard template:

```

Now that you have set up the CONNECTOR_NAME_FROM_METADATA source connector, check out the following CONNECTOR_NAME_FROM_METADATA tutorials:
```

### 'Changelog' section of the documentation follows our guidelines[​](#changelog-section-of-the-documentation-follows-our-guidelines "Direct link to 'Changelog' section of the documentation follows our guidelines")

*Applies to the following connector types: source* *Applies to the following connector languages: python, low-code* *Applies to connector with any support level* *Applies to connector with 300 internal support level* *Applies to connector with any Airbyte usage level*

The user facing connector documentation should follow the guidelines defined in the [standard template](https://github.com/airbytehq/airbyte/blob/master/airbyte-ci/connectors/connectors_qa/src/connectors_qa/checks/documentation/templates/template.md.j2).

Check verifies that Changelog header section content follows standard template:

```
<details>
  <summary>Expand to review</summary>
</details>
```

### Connectors must have a changelog entry for each version[​](#connectors-must-have-a-changelog-entry-for-each-version "Direct link to Connectors must have a changelog entry for each version")

*Applies to the following connector types: source, destination* *Applies to the following connector languages: java, low-code, python, manifest-only* *Applies to connector with any support level* *Applies to connector with 100 internal support level* *Applies to connector with any Airbyte usage level*

Each new version of a connector must have a changelog entry defined in the user facing documentation in `./docs/integrations/<connector-type>s/<connector-name>.md`.

## 📝 Metadata[​](#-metadata "Direct link to 📝 Metadata")

### Connectors must have valid metadata.yaml file[​](#connectors-must-have-valid-metadatayaml-file "Direct link to Connectors must have valid metadata.yaml file")

*Applies to the following connector types: source, destination* *Applies to the following connector languages: java, low-code, python, manifest-only* *Applies to connector with any support level* *Applies to connector with any internal support level* *Applies to connector with any Airbyte usage level*

Connectors must have a `metadata.yaml` file at the root of their directory. This file is used to build our connector registry. Its structure must follow our metadata schema. Field values are also validated. This is to ensure that all connectors have the required metadata fields and that the metadata is valid. More details in this [documentation](https://docs.airbyte.com/connector-development/connector-metadata-file).

### Connector must have a language tag in metadata[​](#connector-must-have-a-language-tag-in-metadata "Direct link to Connector must have a language tag in metadata")

*Applies to the following connector types: source, destination* *Applies to the following connector languages: java, low-code, python, manifest-only* *Applies to connector with any support level* *Applies to connector with any internal support level* *Applies to connector with any Airbyte usage level*

Connectors must have a language tag in their metadata. It must be set in the `tags` field in metadata.yaml. The values can be `language:python` or `language:java`. This checks infers the correct language tag based on the presence of certain files in the connector directory.

### Python connectors must have a CDK tag in metadata[​](#python-connectors-must-have-a-cdk-tag-in-metadata "Direct link to Python connectors must have a CDK tag in metadata")

*Applies to the following connector types: source, destination* *Applies to the following connector languages: python, low-code* *Applies to connector with any support level* *Applies to connector with any internal support level* *Applies to connector with any Airbyte usage level*

Python connectors must have a CDK tag in their metadata. It must be set in the `tags` field in metadata.yaml. The values can be `cdk:low-code`, `cdk:python`, or `cdk:file`.

### Breaking change deadline should be a week in the future[​](#breaking-change-deadline-should-be-a-week-in-the-future "Direct link to Breaking change deadline should be a week in the future")

*Applies to the following connector types: source, destination* *Applies to the following connector languages: java, low-code, python, manifest-only* *Applies to connector with any support level* *Applies to connector with any internal support level* *Applies to connector with any Airbyte usage level*

If the connector version has a breaking change, the deadline field must be set to at least a week in the future.

### Certified source connector must have a value filled out for maxSecondsBetweenMessages in metadata[​](#certified-source-connector-must-have-a-value-filled-out-for-maxsecondsbetweenmessages-in-metadata "Direct link to Certified source connector must have a value filled out for maxSecondsBetweenMessages in metadata")

*Applies to the following connector types: source* *Applies to the following connector languages: java, low-code, python, manifest-only* *Applies to connector with certified support level* *Applies to connector with any internal support level* *Applies to connector with any Airbyte usage level*

Certified source connectors must have a value filled out for `maxSecondsBetweenMessages` in metadata. This value represents the maximum number of seconds we could expect between messages for API connectors. And it's used by platform to tune connectors heartbeat timeout. The value must be set in the 'data' field in connector's `metadata.yaml` file.

## 📦 Packaging[​](#-packaging "Direct link to 📦 Packaging")

### Connectors must use Poetry for dependency management[​](#connectors-must-use-poetry-for-dependency-management "Direct link to Connectors must use Poetry for dependency management")

*Applies to the following connector types: source, destination* *Applies to the following connector languages: python, low-code* *Applies to connector with any support level* *Applies to connector with any internal support level* *Applies to connector with any Airbyte usage level*

Connectors must use [Poetry](https://python-poetry.org/) for dependency management. This is to ensure that all connectors use a dependency management tool which locks dependencies and ensures reproducible installs.

### Connectors must be licensed under MIT or Elv2[​](#connectors-must-be-licensed-under-mit-or-elv2 "Direct link to Connectors must be licensed under MIT or Elv2")

*Applies to the following connector types: source, destination* *Applies to the following connector languages: java, low-code, python, manifest-only* *Applies to connector with any support level* *Applies to connector with any internal support level* *Applies to connector with any Airbyte usage level*

Connectors must be licensed under the MIT or Elv2 license. This is to ensure that all connectors are licensed under a permissive license. More details in our [License FAQ](https://docs.airbyte.com/developer-guides/licenses/license-faq).

### Connector license in metadata.yaml and pyproject.toml file must match[​](#connector-license-in-metadatayaml-and-pyprojecttoml-file-must-match "Direct link to Connector license in metadata.yaml and pyproject.toml file must match")

*Applies to the following connector types: source, destination* *Applies to the following connector languages: python, low-code* *Applies to connector with any support level* *Applies to connector with any internal support level* *Applies to connector with any Airbyte usage level*

Connectors license in metadata.yaml and pyproject.toml file must match. This is to ensure that all connectors are consistently licensed.

### Connector version must follow Semantic Versioning[​](#connector-version-must-follow-semantic-versioning "Direct link to Connector version must follow Semantic Versioning")

*Applies to the following connector types: source, destination* *Applies to the following connector languages: java, low-code, python, manifest-only* *Applies to connector with any support level* *Applies to connector with any internal support level* *Applies to connector with any Airbyte usage level*

Connector version must follow the Semantic Versioning scheme. This is to ensure that all connectors follow a consistent versioning scheme. Refer to our [Semantic Versioning for Connectors](https://docs.airbyte.com/contributing-to-airbyte/#semantic-versioning-for-connectors) for more details.

### Connector version in metadata.yaml and pyproject.toml file must match[​](#connector-version-in-metadatayaml-and-pyprojecttoml-file-must-match "Direct link to Connector version in metadata.yaml and pyproject.toml file must match")

*Applies to the following connector types: source, destination* *Applies to the following connector languages: python, low-code* *Applies to connector with any support level* *Applies to connector with any internal support level* *Applies to connector with any Airbyte usage level*

Connector version in metadata.yaml and pyproject.toml file must match. This is to ensure that connector release is consistent.

### Python connectors must have PyPi publishing declared.[​](#python-connectors-must-have-pypi-publishing-declared "Direct link to Python connectors must have PyPi publishing declared.")

*Applies to the following connector types: source* *Applies to the following connector languages: python, low-code* *Applies to connector with any support level* *Applies to connector with any internal support level* *Applies to connector with any Airbyte usage level*

Python connectors must have [PyPi](https://pypi.org/) publishing enabled in their `metadata.yaml` file. This is declared by setting `remoteRegistries.pypi.enabled` to `true` in metadata.yaml. This is to ensure that all connectors can be published to PyPi and can be used in `PyAirbyte`.

### Manifest-only connectors must use `source-declarative-manifest` as their base image[​](#manifest-only-connectors-must-use-source-declarative-manifest-as-their-base-image "Direct link to manifest-only-connectors-must-use-source-declarative-manifest-as-their-base-image")

*Applies to the following connector types: source, destination* *Applies to the following connector languages: manifest-only* *Applies to connector with any support level* *Applies to connector with any internal support level* *Applies to connector with any Airbyte usage level*

Manifest-only connectors must use `airbyte/source-declarative-manifest` as their base image.

## 💼 Assets[​](#-assets "Direct link to 💼 Assets")

### Connectors must have an icon[​](#connectors-must-have-an-icon "Direct link to Connectors must have an icon")

*Applies to the following connector types: source, destination* *Applies to the following connector languages: java, low-code, python, manifest-only* *Applies to connector with any support level* *Applies to connector with any internal support level* *Applies to connector with any Airbyte usage level*

Each connector must have an icon available in at the root of the connector code directory. It must be an SVG file named `icon.svg` and must be a square.

## 🔒 Security[​](#-security "Direct link to 🔒 Security")

### Connectors must use HTTPS only[​](#connectors-must-use-https-only "Direct link to Connectors must use HTTPS only")

*Applies to the following connector types: source, destination* *Applies to the following connector languages: java, low-code, python, manifest-only* *Applies to connector with any support level* *Applies to connector with any internal support level* *Applies to connector with any Airbyte usage level*

Connectors must use HTTPS only when making requests to external services.

### Python connectors must not use a Dockerfile and must declare their base image in metadata.yaml file[​](#python-connectors-must-not-use-a-dockerfile-and-must-declare-their-base-image-in-metadatayaml-file "Direct link to Python connectors must not use a Dockerfile and must declare their base image in metadata.yaml file")

*Applies to the following connector types: source, destination* *Applies to the following connector languages: python, low-code, manifest-only* *Applies to connector with any support level* *Applies to connector with any internal support level* *Applies to connector with any Airbyte usage level*

Connectors must use our Python connector base image (`docker.io/airbyte/python-connector-base`), declared through the `connectorBuildOptions.baseImage` in their `metadata.yaml`. This is to ensure that all connectors use a base image which is maintained and has security updates.

## 🧪 Testing[​](#-testing "Direct link to 🧪 Testing")

### Medium to High Use Connectors must enable acceptance tests[​](#medium-to-high-use-connectors-must-enable-acceptance-tests "Direct link to Medium to High Use Connectors must enable acceptance tests")

*Applies to the following connector types: source* *Applies to the following connector languages: java, low-code, python, manifest-only* *Applies to connector with any support level* *Applies to connector with any internal support level* *Applies to connector with medium, high Airbyte usage level*

Medium to High Use Connectors must enable acceptance tests via the `connectorTestSuitesOptions.suite:acceptanceTests` in their respective metadata.yaml file to ensure that the connector is working as expected.