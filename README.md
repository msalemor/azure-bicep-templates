<div id="top"></div>

[![MIT License][license-shield]][license-url]


<br />
<div align="center">
  <a href="https://github.com/msalemor/azure-bicep-templates">
    <img src="images/bicep-icon.png" alt="Bicep Logo" width="80" height="80">
  </a>

  <h3 align="center">azure-bicep-templates</h3>

  <p align="center">
    A collection of Bicep templates!
    <br />
    <a href="https://docs.microsoft.com/EN-US/azure/azure-resource-manager/bicep/"><strong>Explore Bicep docs »</strong></a>
    <br />
    <br />
  </p>
</div>

<details open>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-repo">About The Repo</a>
      <ul>
        <li><a href="#supported-scenarios">Supported Scenarios</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#try-out-the-templates">Try-out the templates</a></li>
      </ul>
    </li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
  </ol>
</details>
<br>

## About The Repo

A collection of Bicep templates for different enterprise scenarios. Although the templates are not meant to be used as-is, they are meant to be used as a starting point for your own templates. 

Find out more about Bicep [here](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/).

## Supported Scenarios

* [PaaS solution with Private Endpoints](templates/pe-full/README.md)

_For more examples, please refer to [Documentation](https://docs.microsoft.com/EN-US/azure/azure-resource-manager/bicep/)_ 

See the [open issues](https://github.com/msalemor/azure-bicep-templates/issues) for a full list of proposed features (and known issues).

## Getting Started
### Prerequisites

* Azure Subscription: If you don't have an Azure subscription, create a [free account](https://azure.microsoft.com/free/).
* Azure CLI or Powershell for deploying bicep templates
* Azure Bicep VS Code [Extension](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/install#vs-code-and-bicep-extension) for intellisense, code navigation, and more (optional)

### Try out the templates
go to the desired template folder and run:

```bash
# bash
az deployment group create --template-file main.bicep --parameters <params>
```
or
```pwsh
# Pwsh
New-AzResourceGroupDeployment -TemplateFile ./main.bicep <params>
```

## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

Distributed under the MIT License. See `LICENSE.txt` for more information.

<p align="right">(<a href="#top">back to top</a>)</p>

[license-shield]: https://img.shields.io/github/license/msalemor/azure-bicep-templates.svg?style=for-the-badge
[license-url]: https://github.com/msalemor/azure-bicep-templates/blob/master/LICENSE.txt