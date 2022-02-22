import yaml
import sys 

with open("vars.yaml", 'r') as f:
    valuesYaml = yaml.load(f, Loader=yaml.FullLoader)
    print(valuesYaml[sys.argv[1]][sys.argv[2]])
