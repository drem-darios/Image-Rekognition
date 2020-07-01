export class PostRequest {
    public key: string;
    public AWSAccessKeyId: string;
    public xAmzSecurityToken: string;
    public policy: string;
    public signature: string;
    public url: string;
    constructor(values: Object = {}) { Object.assign(this, values); }
}
