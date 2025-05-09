package validation

import (
	"github.com/suse-edge/edge-image-builder/pkg/image"
)

const (
	versionComponent = "Version"
)

// Note: This method of validating the EIB version in the image definition is only a temporary implementation
// until a more robust solution can be found.
func validateVersion(ctx *image.Context) []FailedValidation {
	var failures []FailedValidation
	definition := *ctx.ImageDefinition

	var apiVersionsDefined bool
	for i := range definition.Kubernetes.Helm.Charts {
		if len(definition.Kubernetes.Helm.Charts[i].APIVersions) != 0 {
			apiVersionsDefined = true
		}
	}

	if definition.APIVersion == "1.0" && apiVersionsDefined {
		failures = append(failures, FailedValidation{
			UserMessage: "Helm chart APIVersions field is not supported in EIB version 1.0, must use EIB version 1.1",
		})
	}

	if definition.APIVersion == "1.0" && definition.OperatingSystem.EnableFIPS {
		failures = append(failures, FailedValidation{
			UserMessage: "Automated FIPS configuration is not supported in EIB version 1.0, please use EIB version >= 1.1",
		})
	}

	if definition.APIVersion != "1.2" && definition.Kubernetes.Network.APIVIP6 != "" {
		failures = append(failures, FailedValidation{
			UserMessage: "IPv6 support for the Kubernetes API VIP is only available in EIB version >= 1.2",
		})
	}

	return failures
}
