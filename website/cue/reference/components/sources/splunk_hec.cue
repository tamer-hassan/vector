package metadata

components: sources: splunk_hec: {
	_port: 8080

	title: "Splunk HTTP Event Collector (HEC)"

	classes: {
		commonly_used: false
		delivery:      "at_least_once"
		deployment_roles: ["aggregator"]
		development:   "stable"
		egress_method: "batch"
		stateful:      false
	}

	features: {
		auto_generated:   true
		acknowledgements: true
		multiline: enabled: false
		receive: {
			from: {
				service: services.splunk

				interface: socket: {
					api: {
						title: "Splunk HEC"
						url:   urls.splunk_hec_protocol
					}
					direction: "incoming"
					port:      _port
					protocols: ["http"]
					ssl: "optional"
				}
			}

			tls: {
				enabled:                true
				can_verify_certificate: true
				enabled_default:        false
			}
		}
	}

	support: {
		requirements: []
		warnings: []
		notices: []
	}

	installation: {
		platform_name: null
	}

	configuration: base.components.sources.splunk_hec.configuration

	output: logs: event: {
		description: "A single event"
		fields: {
			message: fields._raw_line
			splunk_channel: {
				description: "The Splunk channel, value of the `X-Splunk-Request-Channel` header or `channel` query parameter, in that order of precedence."
				required:    true
				type: timestamp: {}
			}
			source_type: {
				description: "The name of the source type."
				required:    true
				type: string: {
					examples: ["splunk_hec"]
				}
			}
			timestamp: fields._current_timestamp
		}
	}

	telemetry: metrics: {
		component_errors_total:               components.sources.internal_metrics.output.metrics.component_errors_total
		component_received_bytes_total:       components.sources.internal_metrics.output.metrics.component_received_bytes_total
		component_received_event_bytes_total: components.sources.internal_metrics.output.metrics.component_received_event_bytes_total
		component_received_events_total:      components.sources.internal_metrics.output.metrics.component_received_events_total
		events_in_total:                      components.sources.internal_metrics.output.metrics.events_in_total
		http_request_errors_total:            components.sources.internal_metrics.output.metrics.http_request_errors_total
		requests_received_total:              components.sources.internal_metrics.output.metrics.requests_received_total
	}

	how_it_works: {
		indexer_acknowledgements: {
			title: "Indexer Acknowledgements"
			body: """
				With acknowledgements enabled, the source uses the [Splunk HEC indexer acknowledgements protocol](https://docs.splunk.com/Documentation/Splunk/8.2.3/Data/AboutHECIDXAck) to allow clients to verify data has been delivered to destination sinks.
				To summarize the protocol, each request to the source is associated with an integer identifier (an ack id) that the client is given and can use to query for the status of the request.
				"""
		}
	}
}
