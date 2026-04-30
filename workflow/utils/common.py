def get_resource(config, rule, resource) -> int:
	'''
    Retrieve resources for a given rule from config.
    Args:
        rule (str): The name of the rule.
        resource (str): The type of resource to retrieve (e.g., 'threads', 'mem_mb').
    Returns:
        int: The requested resource value. 	
    '''

	try:
		return config['resources'][rule][resource]
	except KeyError: 
		print(f'Failed to resolve resource for {rule}/{resource}: using default parameters')
		return config["resources"]['default'][resource]
	
def get_R1_fastqs(units, wc):
	return units.loc[units["sample"] == wc.sample, 'fq1'].to_list()

def get_R2_fastqs(units, wc):
	return units.loc[units["sample"] == wc.sample, 'fq2'].to_list()